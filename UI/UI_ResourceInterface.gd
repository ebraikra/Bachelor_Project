extends Control

# UserInterace-Logik für die Ressourcen
# Passt zum Start des Spiels, beim Platzieren von Gebäuden und am Tagesende die Werte bzw. die "voraussichtlichen" Werte an

@onready var food_label: Label = $VBoxContainer/ResourcesContainer/FoodContainer/FoodLabel
@onready var energy_label: Label = $VBoxContainer/ResourcesContainer/EnergyContainer/EnergyLabel
@onready var wood_label: Label = $VBoxContainer/ResourcesContainer/WoodContainer/WoodLabel
@onready var food_indi = $VBoxContainer/ResourcesContainer/FoodContainer/FoodIndi
@onready var alien_label = $VBoxContainer/ResourcesContainer/AliensContainer/AlienLabel
@onready var food_buff_label = $VBoxContainer/BuffContainer/FoodBuffLabel
@onready var energy_buff_label = $VBoxContainer/BuffContainer/EnergyBuffLabel
@onready var wood_buff_label = $VBoxContainer/BuffContainer/WoodBuffLabel
@onready var buff_manager = %Buffmanager

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	GlobalSignals.DayEnded.connect(_On_Day_Ended)
	GlobalSignals.BuildingPlaced.connect(_On_Building_Placed)
	GlobalSignals.EndQuiz.connect(_On_End_Quiz)
	update_resource_labels()
	update_buff_labels()

func update_resource_labels() -> void:
	# Aktualisiere die Labels mit den aktuellen Werten aus ColonyService
	food_label.text = str(%ColonyService.food)
	wood_label.text = str(%ColonyService.wood)
	energy_label.text = "%s/%s" % [%ColonyService.usedEnergy, %ColonyService.energy]

	# Berechne die voraussichtliche Nahrungsmenge
	var food: int = 0
	for fs: Workstation in %ColonyService.activeFoodStations: # Problema
		var buff_food = buff_manager.get_buff_value("FOOD") * fs.data.produces[BuildingData.BUILDINGCATEGORY.FOOD]
		food += round(buff_food) + fs.data.produces[BuildingData.BUILDINGCATEGORY.FOOD]
	
	var food_balance = food - %ColonyService.GetPopulation().size()
	if food_balance <= 0:
		food_indi.text = "[center][p align=center][color=red]" + str(food_balance - 2)
	else:
		food_indi.text = "[center][p align=center][color=green]+" + str(food_balance - 2)
	
	alien_label.text = "%s/%s" % [str(%ColonyService.GetResidentWithJob().size()), str(%ColonyService.GetPopulation().size())]
	
func update_buff_labels():
	if "FOOD" in buff_manager.active_buffs:
		if buff_manager.active_buffs["FOOD"].value < 0:
			food_buff_label.text = "[color=red]" + str(buff_manager.active_buffs["FOOD"].value * 100) + "%"
		elif buff_manager.active_buffs["FOOD"].value > 0:
			food_buff_label.text = "[color=green]" + str(buff_manager.active_buffs["FOOD"].value * 100) + "%"
			print("foodbuff")
		else:
			food_buff_label.text = ""
	else:
		food_buff_label.text = ""

	if "WOOD" in buff_manager.active_buffs:
		if buff_manager.active_buffs["WOOD"].value < 0:
			wood_buff_label.text = "[color=red]" + str(buff_manager.active_buffs["WOOD"].value * 100) + "%"
		elif buff_manager.active_buffs["WOOD"].value > 0:
			wood_buff_label.text = "[color=green]" + str(buff_manager.active_buffs["WOOD"].value * 100) + "%"
			print("woodbuff")
		else:
			wood_buff_label.text = ""
	else:
		wood_buff_label.text = ""

	if "ENERGY" in buff_manager.active_buffs:
		if buff_manager.active_buffs["ENERGY"].value < 0:
			energy_buff_label.text = "[color=red]" + str(buff_manager.active_buffs["ENERGY"].value * 100) + "%"
		elif buff_manager.active_buffs["ENERGY"].value > 0:
			energy_buff_label.text = "[color=green]" + str(buff_manager.active_buffs["ENERGY"].value * 100) + "%"
			print("energybuff")
		else:
			energy_buff_label.text = ""
	else:
		energy_buff_label.text = ""

func _On_Building_Placed(building: Node) -> void:
	await get_tree().create_timer(1).timeout
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
	
func _On_End_Quiz() -> void:
	await get_tree().create_timer(0.5).timeout
	update_buff_labels()
