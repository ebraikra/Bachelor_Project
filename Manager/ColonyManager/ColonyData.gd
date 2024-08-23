extends Node

#CODELEICHE---------------------------------------------------------------------------------------------

#var population: Array[Alien] = [load("res://Alien.tscn").instantiate(), load("res://Alien.tscn").instantiate()]
#
#var buildings: Array
#var houses: Array[House]
#
#func _ready() -> void:
	#GlobalSignals.BuildingPlaced.connect(_On_BuildingPlaced)
#
#func _On_BuildingPlaced(building: Node2D) -> void:
	#buildings.append(building)
#
#func GetHouses() -> Array:
	#var houses: Array = buildings.filter(
		#func(building: Node2D) -> bool:
			#return building.data.buildingCategory == 3
	#)
	#return houses

#func GetWorkBuilding() -> Array:
	#
