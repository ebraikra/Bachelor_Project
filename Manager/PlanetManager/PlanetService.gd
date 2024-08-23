extends Node

#Service um den aktuellen Tag hochzuzählen, sobald auf "Neuer Tag" gedrückt wurde

var currentDay: int

func _on_button_pressed() -> void:
	GlobalSignals.NewDayStarted.emit()
	currentDay += 1
