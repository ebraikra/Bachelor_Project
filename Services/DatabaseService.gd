extends Node

#Datenbank-Service um die erstellten Gebäude in Data/Buildings/ zu laden

var buildings: Array[BuildingData] = []

func _ready() -> void:
	LoadBuildings("res://Data/Buildings/")

func LoadBuildings(directory: String) -> void:
	for entry in DirAccess.get_directories_at(directory):
		if DirAccess.get_directories_at(directory + "%s" % entry):
			LoadBuildings(directory.get_base_dir() + "/" + entry + "/")
		if DirAccess.get_files_at(directory + "%s" % entry):
			for item in DirAccess.get_files_at(directory + "%s" % entry):
				ResourceLoader.load(directory + entry + "/" + item).set_name(item.get_basename())
				buildings.append(ResourceLoader.load(directory + entry + "/" + item))

func GetBuildings() -> Array[BuildingData]:
	return buildings

