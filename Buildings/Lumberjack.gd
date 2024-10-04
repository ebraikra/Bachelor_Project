class_name Workstation
extends Node2D

#Basislogik für die Produktionsstätten
#Hier ausreichend für Holz&Energie, für die anderen Produktionen gibt's eine extra Klasse
signal building_remove(building: Node2D)

var workers: Array[Alien]
var data: BuildingData
var NEEDED_WORKERS: int
var bodys: Array
var oldMouseCell: Vector2i
var trees: Dictionary
var active: bool = false
@onready var tileMap: TileMap = $Tiles
@onready var chimney: AnimatedSprite2D = $Chimney
@onready var inactive_warning: Sprite2D = $InActiveWarning

func _ready() -> void:
	GlobalSignals.DayEnded.connect(_On_Day_Ended)
	#GlobalSignals.BuildingRemoved.connect(_On_BuildingRemoved)
	NEEDED_WORKERS = data.neededWorkers


#Setzt das Gebäude aktiv/inaktiv, bspw. wenn kein Strom zur Verfügung steht wird es inaktiv
func SetActive(state: bool) -> void:
	if state == false:
		if inactive_warning:
			inactive_warning.show()
	else:
		if inactive_warning:
			inactive_warning.hide()
	active = state

#Rückgabe, ob Gebäude aktiv/inaktiv ist
func IsActive() -> bool:
	return active

#Ruft untere Funktion auf, sobald ein Tag endet
func _On_Day_Ended() -> void:
	chimney.hide()
	SendWorkersHome()

#Schickt die Mitarbeiter NPCs nach Hause. Der Timer ist dafür da, dass sich die NPCs nicht überlappen
func SendWorkersHome() -> void:
	for worker: Alien in workers:
		worker.SendToHome()
		await get_tree().create_timer(0.2).timeout

#Fügt ein NPC dieser Produktionsstätte hinzu, ähnliche Logik wie bei den Häusern
func AddWorker(alien: Alien) -> void:
	workers.append(alien)
	alien.SetWorkplace(self)

#Entfernt NPC vom Gebäude
func RemoveWorker(alien: Alien) -> void:
	workers.erase(alien)
	alien.SetWorkplace(null)

#Abfrage, ob Gebäude NPCs benötigt
func NeedsWorkers() -> bool:
	return !NEEDED_WORKERS == workers.size()

#Rückgabe wie viele NPCs benötigt werden
func GetNeededWorkersAmount() -> int:
	return NEEDED_WORKERS - workers.size()
	
# Eingabeereignis bei Klick auf das Gebäude behandeln
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		print("Building remove, clicked")
		emit_signal("building_remove", self)
