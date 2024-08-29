extends Control

#Logik für das Baumenü UserInterface

var UI_BuildingItem: PackedScene = preload("res://UI/UI_BuildingListItem.tscn")
var uiBI : Node = null
var building : Node = null
var isDesMode: bool = false
var hoveringBuilding: Node2D = null
@onready var colonyService: Node = %ColonyService

func _ready() -> void:
	GlobalSignals.BuildingHover.connect(_On_BuildingHover)
	GlobalSignals.BuildingPlaced.connect(_On_BuildingPlaced)
	GlobalSignals.DayEnded.connect(_On_DayEnded)
	_Update()

func _On_BuildingPlaced(building: Node) -> void:
	_Update()
func _On_DayEnded() -> void:
	_Update()
#Dient dazu, das sobald ein Gebäude platziert wird, nochmal zu checken um weiterhin genügend Ressourcen
#verfügbar sind, falls nicht, werden Gebäude als "NichtBaubar" definiert
func _Update() -> void:
	await get_tree().create_timer(0.1).timeout
	for child in $TabContainer/Wood/MarginContainer/ScrollContainer/HBoxContainer.get_children():
		child.queue_free()
	for child in $TabContainer/Energy/MarginContainer/ScrollContainer/HBoxContainer.get_children():
		child.queue_free()
	for child in $TabContainer/Food/MarginContainer/ScrollContainer/HBoxContainer.get_children():
		child.queue_free()
	for child in $TabContainer/Misc/MarginContainer/ScrollContainer/HBoxContainer.get_children():
		child.queue_free()
	var buildings: Array[BuildingData] = DatabaseService.GetBuildings()
	for building in buildings:
		var canBuild: bool = true
		uiBI = UI_BuildingItem.instantiate()
		uiBI.BuildingSelected.connect(_On_BuildingSelected)
		get_node("TabContainer/" + building.BUILDINGCATEGORY.keys()[building.buildingCategory].to_lower().capitalize() + "/MarginContainer/ScrollContainer/HBoxContainer").add_child(uiBI)
		if colonyService.wood - building.buildingCost <= 0:
			canBuild = false
		else:
			canBuild = true
		uiBI.init(building, canBuild)

#"Klebt" das selektierte Gebäude an die Maus
func _On_BuildingSelected(ButtonBuilding: TextureButton) -> void:
	if %Indicator/DnDHolder.get_child_count() > 0:
		%Indicator/DnDHolder.get_child(0).queue_free()
	var mouse_pos: Vector2 = get_global_mouse_position()
	building = ButtonBuilding.data.buildingNode.instantiate()
	building.data = ButtonBuilding.data
	%Indicator/DnDHolder.add_child(building)
	building.position -= Vector2(-8, -8)

func _On_BuildingHover(building: Node2D) -> void:
	hoveringBuilding = building

#Jegliche Logik bzgl. MausInput
#Handlet das Platzieren von Gebäuden auf der Karte
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB") and %Indicator/DnDHolder.get_child_count() > 0:
		%Indicator/DnDHolder.get_child(0).reparent(%Buildings)
		GlobalSignals.BuildingPlaced.emit(%Buildings.get_child(%Buildings.get_child_count() - 1))
	#Ab hier Codeleiche-------------------------------
	if isDesMode and event.is_action_pressed("LMB") and hoveringBuilding != null:
		if hoveringBuilding.data.buildingCategory != BuildingData.BUILDINGCATEGORY.MISC:
			GlobalSignals.BuildingRemoved.emit(hoveringBuilding)
			for worker: Alien in hoveringBuilding.workers:
				hoveringBuilding.RemoveWorker(worker)
			%ColonyService.buildings.erase(hoveringBuilding)
			hoveringBuilding.queue_free()
		else:
			GlobalSignals.BuildingRemoved.emit(hoveringBuilding)
			for resident: Alien in hoveringBuilding.residents:
				hoveringBuilding.RemoveResident(resident)
			%ColonyService.buildings.erase(hoveringBuilding)
			%ColonyService.accommodations.erase(hoveringBuilding)
			hoveringBuilding.queue_free()
		%ColonyService.wood += hoveringBuilding.data.buildingCost
		

#Codeleiche
func _on_hammer_pressed() -> void:
	var curImg: AtlasTexture = AtlasTexture.new()
	curImg.set_atlas(load("res://Assets/UiIcons.png"))
	curImg.set_region(Rect2(Vector2(2, 2), Vector2(12, 13)))
	Input.set_custom_mouse_cursor(curImg)
	isDesMode = !isDesMode
