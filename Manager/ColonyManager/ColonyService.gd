extends Node

#Eigentliches Herzstück des Ganzen, beinhaltet sämtliche Logik was passieren soll, wenn ein Tag startet, endet etc.

var population: Array[Alien] = [load("res://Alien.tscn").instantiate(), load("res://Alien.tscn").instantiate(), load("res://Alien.tscn").instantiate(), load("res://Alien.tscn").instantiate()]
var food: int = 25
var wood: int = 90
var energy: int = 0
var co2: int = 0
var buildings: Array
var accommodations: Array[Accommodation]
var usedEnergy: int = 0
var activeEnergyStations: Array
var activeFoodStations: Array

@onready var tile_map = $"/root/World/WorldMap"
@onready var buff_manager = %Buffmanager
@onready var quiz = %Quiz

var days: int = 0

#NPCs haben entweder den Status Arbeit oder Schlafen bzw. Nicht-Arbeiten
enum ALIENSTATE {
	WORK,
	SLEEP
}

#Setzt den Status der NPCs direkt zu Beginn auf Schlafen, damit diese erst zu den Häusern laufen
var currentAlienState: ALIENSTATE = ALIENSTATE.SLEEP

func _ready() -> void:
	GlobalSignals.BuildingPlaced.connect(_On_BuildingPlaced)
	GlobalSignals.NewDayStarted.connect(_On_NewDayStarted)
	GlobalSignals.DayEnded.connect(_On_DayEnded)
	#GlobalSignals.EndQuiz.connect(_On_QuizEnded)
	#GlobalSignals.BuildingRemoved.connect(_On_Building_Removed)
	for building in buildings:
		building.connect("building_remove", Callable(self, "_On_Building_Removed")) 

#Sobald ein neuer Tag startet werden alle NPCs zur Arbeit geschickt und nach 5Sek wieder nach Hause geschickt
func _On_NewDayStarted() -> void:
	currentAlienState = ALIENSTATE.WORK
	Engine.time_scale = 1
	await get_tree().create_timer(5).timeout
	GlobalSignals.DayEnded.emit()
	currentAlienState = ALIENSTATE.SLEEP

#Logik wenn der Tag endet
func _On_DayEnded() -> void:
	#Checkt, ob es NPCs im Raumschiff gibt, wenn ja werden diese freien Wohneinheiten zugewiesen
	#print("Buildings at the beginning of DayEnded: ", buildings.size())  # Debugging the size of buildings array
	var activeStations: Array = GetWorkStations().filter(
		func(ws: Workstation) -> bool:
			return ws.IsActive()
	)
	var inactiveStations: Array = GetWorkStations().filter(
		func(ws: Workstation) -> bool:
			return !ws.IsActive()
	)

	#print("Active workstations at the beginning of DayEnded: ", activeStations.size())
	#print("Inactive workstations at the beginning of DayEnded: ", inactiveStations.size())

	AssignWorkersToWorkstations()
	UpdateWorkstations()
	# Aktualisiere Ressourcen basierend auf aktiven Arbeitsplätzen
	UpdateResources()
	
	#Fix wenn alle Gebäude gelöscht werden, geht das ins Minus
	if usedEnergy <= 0: usedEnergy = 0
	if wood <= 0: wood = 0
	#Leitet den Lose-Screen ein, wenn die Nahrung <= 0 gesunken ist
	if food <= 0:
		RoundManager.StartPhase(RoundManager.PHASES.LOSEROUND)
		return
	
	days += 1
	print("Runde: ", days)
	# Ab 5 tagen = Frage aufploppen
	if days % 1 == 0: # Change to 5 days
		if quiz.indexQuestion < quiz.questionsList.size(): 
			GlobalSignals.StartQuiz.emit()
			print("QUIZ GO")
	print("CO2: ", co2)
	
	#Win State
	if GetPopulation().size() >= 100 and co2 == 0 and tile_map.GetAllTrees().size() >= 300: #Game Goal
		RoundManager.StartPhase(RoundManager.PHASES.ROUNDWON)
		%AlienScientist.play("quiz_friendly")
	#print(buildings)

#Ähnliche Logik zu oben, reagiert dieses mal nur darauf wenn ein Gebäude platziert wird
func _On_BuildingPlaced(building: Node2D) -> void:
	wood -= building.data.buildingCost
	buildings.append(building)
	building.connect("building_remove", Callable(self, "_On_Building_Removed"))
	var activeWorkstations = get_active_stations()

	AssignWorkersToWorkstations()
	 # Arbeitsplätze auffüllen
	UpdateWorkstations()
	update_activeFoodStations(activeWorkstations)

				
func AssignWorkersToWorkstations() -> void:
	if %Spaceship.residents.size() > 0:
		if GetCountFreeSpace() > 0:
			for freeAccommodation: Accommodation in GetFreeAccommodations():
				if %Spaceship.residents.size() - freeAccommodation.GetFreeSpace() <= 0:
					for resident: Alien in %Spaceship.residents:
						freeAccommodation.AddResident(resident)
						await get_tree().create_timer(0.2).timeout
					%Spaceship.residents.clear()
					return
				else:
					for i: int in freeAccommodation.GetFreeSpace():
						freeAccommodation.AddResident(%Spaceship.residents.pop_front())
						await get_tree().create_timer(0.2).timeout
	# Zuweisen von Arbeitern zu nicht vollständig besetzten Arbeitsplätzen
	if !GetNotFilledWorkStations().is_empty():
		for workplace: Workstation in GetNotFilledWorkStations():
			if !GetResidentsWithoutJob().is_empty():
				if GetResidentsWithoutJob().size() - workplace.GetNeededWorkersAmount() <= 0:
					for resident: Alien in GetResidentsWithoutJob():
						workplace.AddWorker(resident)
				else:
					for i: int in workplace.GetNeededWorkersAmount():
						workplace.AddWorker(GetResidentsWithoutJob().pop_front())
						
			if workplace.data.buildingCategory == BuildingData.BUILDINGCATEGORY.ENERGY and !workplace.NeedsWorkers():
				var buff_energy = buff_manager.get_buff_value("ENERGY") * workplace.data.produces[BuildingData.BUILDINGCATEGORY.ENERGY]
				energy += round(buff_energy) + workplace.data.produces[BuildingData.BUILDINGCATEGORY.ENERGY]
				workplace.SetActive(true)
				
			if workplace is Solarpanel:
				if !workplace.IsAlreadyPlaced():
					var buff_energy = buff_manager.get_buff_value("ENERGY") * workplace.data.produces[BuildingData.BUILDINGCATEGORY.ENERGY]
					energy += round(buff_energy) + workplace.data.produces[BuildingData.BUILDINGCATEGORY.ENERGY]

func UpdateWorkstations() -> void:
	var inactiveStations: Array = GetWorkStations().filter(
		func(ws: Workstation) -> bool:
			return !ws.IsActive()
	)
	var activeStations: Array = GetWorkStations().filter(
		func(ws: Workstation) -> bool:
			return ws.IsActive()
	)
	#Checkt, ob die Energiekosten einzelner inaktiver Arbeitsplätze nicht der Gesamtenergie überschreiten.
	#Wenn nicht, wird die Energie verbraucht und das Gebäude aktiv gesetzt
	for ws: Workstation in inactiveStations:
		if ws.data.energyCost + usedEnergy <= energy:
			ws.SetActive(true)
			usedEnergy += ws.data.energyCost
		else:
			ws.SetActive(false)
	#Durchläuft alle Gebäude die nicht mit Energie versort werden können und schaltet die aus.
	for ws: Workstation in activeStations:
		if usedEnergy > energy:
			ws.SetActive(false)
			usedEnergy -= ws.data.energyCost
		else:
			break
	#print("Active workstations: ", activeStations.size())  # Debugging
func get_active_stations() -> Array:
	# Holen Sie sich alle Arbeitsstationen, die aktiv und gefüllt sind
	var activeWorkstations: Array = GetWorkStations().filter(
		func(ws: Workstation) -> bool:
			return !GetNotFilledWorkStations().has(ws) and ws.IsActive()
	)
	return activeWorkstations
# Aktualisiert Aktive FoodStations
func update_activeFoodStations(activeWorkstations) -> void:
	activeFoodStations = activeWorkstations.filter(func(ws: Workstation) -> bool:
		return ws.data.buildingCategory == BuildingData.BUILDINGCATEGORY.FOOD and ws.IsActive()
	)
	
func UpdateResources() -> void:
	#Filtert alle aktiven Arbeitsplätze
	var activeWorkstations = get_active_stations()
	update_activeFoodStations(activeWorkstations)
	var countWoodProduction: int = 0
	#Sammelt die Ressourcen der aktiven Arbeitsplätze
	for workstation: Workstation in activeWorkstations:
		#energy += workstation.data.produces[BuildingData.BUILDINGCATEGORY.ENERGY]
		var buff_food = buff_manager.get_buff_value("FOOD") * workstation.data.produces[BuildingData.BUILDINGCATEGORY.FOOD]
		var buff_wood = buff_manager.get_buff_value("WOOD") * workstation.data.produces[BuildingData.BUILDINGCATEGORY.WOOD]
		food += round(buff_food) + workstation.data.produces[BuildingData.BUILDINGCATEGORY.FOOD]
		wood += round(buff_wood) + workstation.data.produces[BuildingData.BUILDINGCATEGORY.WOOD]
		countWoodProduction += workstation.data.produces[BuildingData.BUILDINGCATEGORY.WOOD]
		co2 += workstation.data.co2
	var treeCounter: int = 0
	if tile_map:
		tile_map.delete_trees_on_produced_wood(countWoodProduction, treeCounter)
	else:
		print("TileMap reference is null, cannot call the function.")
	#Eventuelle Codeleiche?-------------------------
	#activeFoodStations = activeWorkstations.filter(func(ws: Workstation) -> bool:
		#return ws.data.buildingCategory == BuildingData.BUILDINGCATEGORY.FOOD and ws.IsActive())	
	
	#Anzahl der Bäume verringert den aktuellen CO2 Wert, 1 Baum = -1 CO2 
	co2 -= %WorldMap.GetAllTrees().size()
	#Ruft den Smogfilter auf und gibt über den aktuellen Stand des CO2-Werts bescheid
	%Smog.update_co2(co2)
	#Startet den Analysebericht, wenn es mindestens eine Analyse gibt
	if %Analysis.getAnalysisCount() > 0:
		%Analysis.StartNewAnalysis()
	if co2 <= 0: co2 = 0
	#Ein NPC benötigt pro Tag eine Einheit Essen, diese wird hier abgezogen
	#print("Population size before food deduction: ", GetPopulation().size())
	food -= GetPopulation().size()
	#print("Food after deduction: ", food)

func _On_Building_Removed(building: Node2D) -> void:
	var activeWorkstations = get_active_stations()
	if building == null:
		print("Error: Trying to remove a null building!")  # Debugging
		return
	if building.data.buildingCategory != BuildingData.BUILDINGCATEGORY.ENERGY:
		if building in buildings:
			print("Removing building: ", building.data.buildingCategory)
			if !building.NeedsWorkers():
				usedEnergy -= building.data.energyCost
				if usedEnergy <= 0: usedEnergy = 0
			buildings.erase(building)
			building.queue_free()
			building = null
			AssignWorkersToWorkstations()
			UpdateWorkstations()
			update_activeFoodStations(activeWorkstations)
			print("Building removed from buildings list. Remaining buildings: ", buildings.size())
	elif building.data.buildingCategory == BuildingData.BUILDINGCATEGORY.ENERGY:
		if building in buildings:
			print("energy:", energy)
			print(building.data.produces[BuildingData.BUILDINGCATEGORY.ENERGY])
			if !building.NeedsWorkers():
				energy -= building.data.produces[BuildingData.BUILDINGCATEGORY.ENERGY]
			print("energydecrease:", energy)
			buildings.erase(building)
			building.queue_free()
			building = null
			AssignWorkersToWorkstations()
			UpdateWorkstations()
			update_activeFoodStations(activeWorkstations)
			print("Building removed from buildings list. Remaining buildings: ", buildings.size())
	
	
	
	var activeStations: Array = GetWorkStations().filter(
		func(ws: Workstation) -> bool:
			return ws.IsActive()
	)
	#print("Active workstations after removed building: ", activeStations.size())

func getLumberjacks() -> Array:
	return buildings.filter(
		func(building: Node2D) -> bool:
			return building.data.buildingCategory == BuildingData.BUILDINGCATEGORY.WOOD
	)
func getEnergystations() -> Array:
	return buildings.filter(
		func(building: Node2D) -> bool:
			return building.data.buildingCategory == BuildingData.BUILDINGCATEGORY.ENERGY
	)
	
#Rückgabe aller Wohneinheiten
func GetAccommodations() -> Array:
	return buildings.filter(
		func(building: Node2D) -> bool:
			return building.data.buildingCategory == BuildingData.BUILDINGCATEGORY.MISC
	)

#Rückgabe aller Arbeitsplätze
func GetWorkStations() -> Array:
	return buildings.filter(
		func(building: Node2D) -> bool:
			return building.data.buildingCategory != BuildingData.BUILDINGCATEGORY.MISC
	)

#Rückgabe aller Arbeitsplätze die NPCs benötigen
func GetNotFilledWorkStations() -> Array:
	return GetWorkStations().filter(
		func(workstation: Workstation) -> bool:
			return workstation.NeedsWorkers()
	)

#Rückgabe wie viele NPCs ein Arbeitsplatz benötigt
func GetCountWorkersNeeded() -> int:
	var workersNeeded: int
	for workstation: Workstation in GetNotFilledWorkStations():
		workersNeeded += workstation.GetNeededWorkersAmount()
	return workersNeeded

#Rückgabe aller freien Wohneinheiten, die Platz für NPCs haben
func GetFreeAccommodations() -> Array:
	return GetAccommodations().filter(
		func(accommodation: Node2D) -> bool:
			return accommodation.HasSpace()
	)

#Rückgabe wie viel Platz eine freie Wohneinheit hat
func GetCountFreeSpace() -> int:
	var freeSpace: int
	for freeAccommodation: Node2D in GetFreeAccommodations():
		freeSpace += freeAccommodation.GetFreeSpace()
	return freeSpace

#Rückgabe wie viele NPCs derzeit leben
func GetPopulation() -> Array:
	return %Colony.get_children()

#Rückgabe aller NPCs die keine Arbeit haben
func GetResidentsWithoutJob() -> Array:
	var residentsWithHome: Array = GetPopulation().filter(
		func(resident: Alien) -> bool:
			return resident.GetHome() != null
	)
	return residentsWithHome.filter(
		func(resident: Alien) -> bool:
			return resident.GetWorkplace() == null
	)

#Rückgabe aller NPCs die eine Arbeit haben
func GetResidentWithJob() -> Array:
	var residentsWithHome: Array = GetPopulation().filter(
		func(resident: Alien) -> bool:
			return resident.GetHome() != null
	)
	return residentsWithHome.filter(
		func(resident: Alien) -> bool:
			return resident.GetWorkplace() != null
	)

func getEnergy():
	return energy
	
func setEnergy(value):
	energy = value
