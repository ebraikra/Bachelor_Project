extends Control

# UserInterace-Logik für die Ressourcen
# Passt zum Start des Spiels, beim Platzieren von Gebäuden und am Tagesende die Werte bzw. die "voraussichtlichen" Werte an

@onready var food_label: Label = $ResourcesContainer/FoodContainer/FoodLabel
@onready var energy_label: Label = $ResourcesContainer/EnergyContainer/EnergyLabel
@onready var wood_label: Label = $ResourcesContainer/WoodContainer/WoodLabel
@onready var food_indi = $ResourcesContainer/FoodContainer/FoodIndi
@onready var alien_label = $ResourcesContainer/AliensContainer/AlienLabel

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	GlobalSignals.DayEnded.connect(_On_Day_Ended)
	GlobalSignals.BuildingPlaced.connect(_On_Building_Placed)
	update_resource_labels()

func update_resource_labels() -> void:
	# Aktualisiere die Labels mit den aktuellen Werten aus ColonyService
	food_label.text = str(%ColonyService.food)
	wood_label.text = str(%ColonyService.wood)
	energy_label.text = "%s/%s" % [%ColonyService.usedEnergy, %ColonyService.energy]

	# Berechne die voraussichtliche Nahrungsmenge
	var food: int = 0
	for fs: Workstation in %ColonyService.activeFoodStations: # Problema
		food += fs.data.produces[BuildingData.BUILDINGCATEGORY.FOOD]
	
	var food_balance = food - %ColonyService.GetPopulation().size()
	if food_balance <= 0:
		food_indi.text = "[center][p align=center][color=red]" + str(food_balance - 1)
	else:
		food_indi.text = "[center][p align=center][color=green]+" + str(food_balance - 1)
	
	alien_label.text = "%s/%s" % [str(%ColonyService.GetResidentWithJob().size()), str(%ColonyService.GetPopulation().size())]

func _On_Building_Placed(building: Node) -> void:
	await get_tree().create_timer(1).timeout
	building.connect("building_remove", Callable(self, "_On_Building_Removed")) 
	update_resource_labels()

func _On_Building_Removed() -> void:
	await get_tree().create_timer(0.5).timeout
	food_label.text = str(%ColonyService.food)
	wood_label.text = str(%ColonyService.wood)
	energy_label.text = "%s/%s" %  [%ColonyService.usedEnergy, %ColonyService.energy]
	match %ColonyService.food - %ColonyService.GetPopulation().size() <= 0:
		false:
			food_indi.text = "[color=green][center][p align=center]++"
		true:
			food_indi.text = "[color=red][center][p align=center]--"

func _On_Day_Ended() -> void:
	await get_tree().create_timer(0.5).timeout
	update_resource_labels()
