class_name Accommodation
extends Node2D

#Logik für die Häuser in den die NPCs leben

const MAX_RESIDENTS = 2
var residents: Array[Alien]
var data: BuildingData = load("res://Data/Buildings/Buildings/House.tres")

func _ready() -> void:
	GlobalSignals.NewDayStarted.connect(_On_NewDayStarted)

#NPC wird Haus zugewiesen
func AddResident(alien: Alien) -> void:
	residents.append(alien)
	alien.SetHome(self)
	alien.SendToHome()

#NPC wird vom Haus entfernt
func RemoveResident(alien: Alien) -> void:
	residents.erase(alien)
	alien.SetHome(null)

#Abfrage ob Haus Platz hat
func HasSpace() -> bool:
	return !MAX_RESIDENTS == residents.size()

#Gibt Anzahl freier Plätze im Haus zurück
func GetFreeSpace() -> int:
	return MAX_RESIDENTS - residents.size()

#Funktion schickt alle Bewohner des Hauses die eine Arbeit haben zur Arbeit
func SendResidentsToWork() -> void:
	for resident: Alien in residents:
		if resident.GetWorkplace() != null:
			if !resident.GetWorkplace().NeedsWorkers() and resident.GetWorkplace().IsActive():
				resident.SendToWork()
				await get_tree().create_timer(0.2).timeout

#Ruft o.g. Funktion auf, so bald ein neuer Tag beginnt
func _On_NewDayStarted() -> void:
	SendResidentsToWork()
