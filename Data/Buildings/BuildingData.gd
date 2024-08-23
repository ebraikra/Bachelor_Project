class_name BuildingData
extends Resource

#Data-Klasse für Gebäude, alle benötigten Daten hier vordefiniert um später einzupflegen - Ähnlich Interface

enum BUILDINGCATEGORY {
	ENERGY,
	FOOD,
	WOOD,
	MISC,
}

@export var name: String
@export var texture: Texture
@export_multiline var description: String
@export var buildingNode: PackedScene
@export var buildingCategory : BUILDINGCATEGORY:
	get:
		return buildingCategory
@export var buildingCost: int
@export var energyCost: int
@export var co2: float
