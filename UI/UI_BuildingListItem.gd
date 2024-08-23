extends TextureButton

#UserInterface-Logik für ein einzelnes Gebäude, welches dann im Baumenü angezeigt wird
#Beim Init werden direkt die Daten eingeplegt um welches Gebäude es sich handelt etc.

signal BuildingSelected
@onready var warn_icon: TextureRect = $WarnIcon
@onready var stats: Panel = $Stats

var data: BuildingData

@onready var title: Label = $Stats/MarginContainer/VBoxContainer/Title
@onready var desc: RichTextLabel = $Stats/MarginContainer/VBoxContainer/Desc
#@onready var buildStats: Label = $Stats/MarginContainer/VBoxContainer/Stats
@onready var sep: HSeparator = $Stats/MarginContainer/VBoxContainer/Sep
@onready var prod_energy_label: Label = $Stats/MarginContainer/VBoxContainer/HSplitContainer/produce_con/EnergyContainer/Label
@onready var prod_food_label: Label = $Stats/MarginContainer/VBoxContainer/HSplitContainer/produce_con/FoodContainer/Label
@onready var prod_wood_label: Label = $Stats/MarginContainer/VBoxContainer/HSplitContainer/produce_con/WoodContainer/Label
@onready var cons_energy_label: Label = $Stats/MarginContainer/VBoxContainer/HSplitContainer/consumes_con/EnergyContainer/Label
@onready var cons_food_label: Label = $Stats/MarginContainer/VBoxContainer/HSplitContainer/consumes_con/FoodContainer/Label
@onready var cons_wood_label: Label = $Stats/MarginContainer/VBoxContainer/HSplitContainer/consumes_con/WoodContainer/Label
@onready var cons_alien_label: Label = $Stats/MarginContainer/VBoxContainer/HSplitContainer/consumes_con/AlienContainer/Label
@onready var prod_energy_container: HBoxContainer = $Stats/MarginContainer/VBoxContainer/HSplitContainer/produce_con/EnergyContainer
@onready var prod_food_container: HBoxContainer = $Stats/MarginContainer/VBoxContainer/HSplitContainer/produce_con/FoodContainer
@onready var prod_wood_container: HBoxContainer = $Stats/MarginContainer/VBoxContainer/HSplitContainer/produce_con/WoodContainer
@onready var cons_energy_container: HBoxContainer = $Stats/MarginContainer/VBoxContainer/HSplitContainer/consumes_con/EnergyContainer
@onready var cons_food_container: HBoxContainer = $Stats/MarginContainer/VBoxContainer/HSplitContainer/consumes_con/FoodContainer
@onready var cons_wood_container: HBoxContainer = $Stats/MarginContainer/VBoxContainer/HSplitContainer/consumes_con/WoodContainer
@onready var produce_con: VBoxContainer = $Stats/MarginContainer/VBoxContainer/HSplitContainer/produce_con
@onready var cons_alien_container: HBoxContainer = $Stats/MarginContainer/VBoxContainer/HSplitContainer/consumes_con/AlienContainer



func init(_data: BuildingData, canBuild: bool) -> void:
	if not _data: return
	data = _data
	$Icon.set_texture(data.texture)
	if canBuild:
		warn_icon.hide()
		disabled = false
	else:
		warn_icon.show()
		disabled = true
	title.set_text(data.name)
	desc.set_text(data.description)
	if data is WorkplaceData:
		if data.produces.get(0) != 0:
			prod_energy_label.set_text("+" + str(data.produces.get(0)))
			prod_energy_container.show()
		if data.produces.get(1) != 0:
			prod_food_label.set_text("+" + str(data.produces.get(1)))
			prod_food_container.show()
		if data.produces.get(2) != 0:
			prod_wood_label.set_text("+" + str(data.produces.get(2)))
			prod_wood_container.show()
		if data.neededWorkers != 0:
			cons_alien_container.show()
			cons_alien_label.set_text("-" + str(data.neededWorkers))
	else:
		produce_con.hide()
	if data.energyCost != 0:
		cons_energy_label.set_text("-" + str(data.energyCost))
		cons_energy_container.show()
	if data.buildingCost != 0:
		cons_wood_label.set_text("-" + str(data.buildingCost))
		cons_wood_container.show()

func _on_pressed() -> void:
	BuildingSelected.emit(self)


func _on_mouse_entered() -> void:
	stats.show()


func _on_mouse_exited() -> void:
	stats.hide()
