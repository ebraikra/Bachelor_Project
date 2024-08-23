class_name WorkplaceData
extends BuildingData

#Data-Klasse für Produktionsstätten, alle benötigten Daten hier vordefiniert um später einzupflegen - Ähnlich Interface
#Erweitert die Data-Klasse für Gebäude

@export var neededWorkers: int
@export var produces: Dictionary = {BUILDINGCATEGORY.ENERGY: 1, BUILDINGCATEGORY.FOOD: 1, BUILDINGCATEGORY.WOOD: 1}

