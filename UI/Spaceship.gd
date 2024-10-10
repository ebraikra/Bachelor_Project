extends Node2D

#Logik für das Raumschiff
#Dient als Spawnpunkt für neue NPCs und gleichzeitig als Wohnort, falls kein freier Wohnort verfügbar ist

var residents : Array[Alien]
const ALIEN = preload("res://Alien.tscn")
@onready var res_count: Label = $ResPanel/ResCount
@onready var res_panel: Panel = $ResPanel

func _ready() -> void:
	GlobalSignals.DayEnded.connect(_On_Day_Ended)
	GlobalSignals.BuildingPlaced.connect(_On_Building_Placed)
#	GlobalSignals.BuildingRemoved.connect(_On_Building_Removed)
	residents = %ColonyService.population
	for resident in residents:
		%Colony.add_child(resident)
		resident.position = position
	if !residents.is_empty():
		res_panel.show()
		res_count.text = str(residents.size()) + "x"
	else:
		res_panel.hide()

#Codeleiche
#func _On_Building_Removed(building: Node2D) -> void:
	#if building.data.buildingCategory == BuildingData.BUILDINGCATEGORY.MISC:
		#for resident: Alien in building.residents:
			#residents.append(resident)
			#resident.position = position
			#resident.show()

#Erzeugt zwei neue NPCs am Ende eines Tages
func _On_Day_Ended() -> void:
	var alien: Alien = ALIEN.instantiate()
	residents.append(alien)
	alien.position = position
	%Colony.add_child(alien)
	alien = ALIEN.instantiate()
	residents.append(alien)
	alien.position = position
	%Colony.add_child(alien)
	await get_tree().create_timer(0.4).timeout
	if !residents.is_empty():
		res_panel.show()
		res_count.text = str(residents.size()) + "x"
	else:
		res_panel.hide()

#Updated den Text über dem Raumschiff, die anzeigt wie viele NPCs derzeit im Raumschiff leben
#Wird aufgerufen, sobald ein Gebäude platziert wurde
func _On_Building_Placed(building: Node) -> void:
	await get_tree().create_timer(0.4).timeout
	if !residents.is_empty():
		res_panel.show()
		res_count.text = str(residents.size())
	else:
		res_panel.hide()
