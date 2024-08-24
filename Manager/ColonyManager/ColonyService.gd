extends Node

#Eigentliches Herzstück des Ganzen, beinhaltet sämtliche Logik was passieren soll, wenn ein Tag startet, endet etc.
#Balancing wurde noch nicht vorgenommen, weshalb das Spiel sehr unbalanced wirken kann

var population: Array[Alien] = [load("res://Alien.tscn").instantiate(), load("res://Alien.tscn").instantiate(), load("res://Alien.tscn").instantiate(), load("res://Alien.tscn").instantiate()]
var food: int = 25
var wood: int = 150
var energy: int = 0
var co2: int = 0
var buildings: Array
var accommodations: Array[Accommodation]
var usedEnergy: int = 0
var activeEnergyStations: Array
var activeFoodStations: Array

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
	if %Spaceship.residents.size() > 0:
		if GetCountFreeSpace() > 0:
			for freeAccommodation: Accommodation in GetFreeAccommodations():
				if %Spaceship.residents.size() - freeAccommodation.GetFreeSpace() <= 0:
					for resident: Alien in %Spaceship.residents:
						freeAccommodation.AddResident(resident)
						await get_tree().create_timer(0.2).timeout
						%Spaceship.residents.clear()
				else:
					for i: int in freeAccommodation.GetFreeSpace():
						freeAccommodation.AddResident(%Spaceship.residents.pop_front())
						await get_tree().create_timer(0.2).timeout
	#Checkt, ob es Arbeitsplätze gibt denen es an Arbeitskräften mangelt, wenn ja werden die NPCs ohne
	#Job rausgefiltert und zugewiesen
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
				#if !activeEnergyStations.find(workplace):
					#activeEnergyStations.append(workplace)
				energy += workplace.data.produces[BuildingData.BUILDINGCATEGORY.ENERGY]
	#Filtert alle Arbeitsplätze die aufgrund zu wenig Strom inaktiv sind
	var inactiveStations: Array = GetWorkStations().filter(
		func(ws: Workstation) -> bool:
			return !ws.IsActive()
	)
	#Checkt, ob die Energiekosten einzelner inaktiver Arbeitsplätze nicht der Gesamtenergie überschreiten.
	#Wenn nicht, wird die Energie verbraucht und das Gebäude aktiv gesetzt
	for ws: Workstation in inactiveStations:
		if ws.data.energyCost + usedEnergy <= energy:
			ws.SetActive(true)
			usedEnergy += ws.data.energyCost
		else:
			ws.SetActive(false)
	#Filtert alle aktiven Arbeitsplätze
	var activeWorkstations: Array = GetWorkStations().filter(
		func(ws: Workstation) -> bool:
			return !GetNotFilledWorkStations().has(ws) and ws.IsActive())

	var countWoodProduction: int = 0
	#Sammelt die Ressourcen der aktiven Arbeitsplätze
	for workstation: Workstation in activeWorkstations:
		#energy += workstation.data.produces[BuildingData.BUILDINGCATEGORY.ENERGY]
		food += workstation.data.produces[BuildingData.BUILDINGCATEGORY.FOOD]
		wood += workstation.data.produces[BuildingData.BUILDINGCATEGORY.WOOD]
		countWoodProduction += workstation.data.produces[BuildingData.BUILDINGCATEGORY.WOOD]
		co2 += workstation.data.co2
	var treeCounter: int = 0
	if tile_map:
		tile_map.delete_trees_on_produced_wood(countWoodProduction, treeCounter)
		print("yes")
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
	food -= GetPopulation().size()
	#Leitet den Lose-Screen ein, wenn die Nahrung <= 0 gesunken ist
	if food <= 0:
		RoundManager.StartPhase(RoundManager.PHASES.LOSEROUND)
		return
	
	# ToDo: Hochzählen von Tagen
	days += 1
	print(days)
	# Ab 5 tagen = Frage aufploppen
	if days % 5 == 0:
		print("Fragen")

#Ähnliche Logik zu oben, reagiert dieses mal nur darauf wenn ein Gebäude platziert wird
func _On_BuildingPlaced(building: Node2D) -> void:
	wood -= building.data.buildingCost
	buildings.append(building)
	
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
	if !GetNotFilledWorkStations().is_empty():
		for workplace: Workstation in GetNotFilledWorkStations():
			if GetResidentsWithoutJob().is_empty():
				return
			else:
				if GetResidentsWithoutJob().size() - workplace.GetNeededWorkersAmount() <= 0:
					for resident: Alien in GetResidentsWithoutJob():
						workplace.AddWorker(resident)
				else:
					for i: int in workplace.GetNeededWorkersAmount():
						workplace.AddWorker(GetResidentsWithoutJob().pop_front())
			if workplace.data.buildingCategory == BuildingData.BUILDINGCATEGORY.ENERGY and !workplace.NeedsWorkers():
				energy += workplace.data.produces[BuildingData.BUILDINGCATEGORY.ENERGY]
	var inactiveStations: Array = GetWorkStations().filter(
		func(ws: Workstation) -> bool:
			return !ws.IsActive()
	)
	for ws: Workstation in inactiveStations:
		if ws.data.energyCost + usedEnergy <= energy:
			ws.SetActive(true)
			usedEnergy += ws.data.energyCost
		else:
			ws.SetActive(false)
	
	var activeWorkstations: Array = GetWorkStations().filter(
		func(ws: Workstation) -> bool:
			return !GetNotFilledWorkStations().has(ws))
	
	activeFoodStations = activeWorkstations.filter(func(ws: Workstation) -> bool:
		return ws.data.buildingCategory == BuildingData.BUILDINGCATEGORY.FOOD and ws.IsActive())

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
