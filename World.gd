extends Node2D


#Connecten von Signalen
func _ready() -> void:
	GlobalSignals.NewDayStarted.connect(_On_NewDay_Started)
	GlobalSignals.DayEnded.connect(_On_Day_Ended)
	RoundManager.RoundLost.connect(_On_RoundLost)

#Deaktiviert den "Neuer Tag" Button, um potentiellen Fehlern entgegen zu wirken
func _On_NewDay_Started() -> void:
	$CanvasLayer/Button.disabled = true

#Reaktiviert den "Neuer Tag" Button, so bald der Tag beendet ist
func _On_Day_Ended() -> void:
	$CanvasLayer/Button.disabled = false

#Zeigt die Verloren-Übersicht an
func _On_RoundLost() -> void:
	$CanvasLayer/LosePanel.show()

#Sorgt dafür, das Gebäude an das Spielgitter "gesnapped" werden
func _unhandled_input(event: InputEvent) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	$Camera2D/Indicator.global_position = Vector2(
		snapped(get_global_mouse_position().x - 8, 16),
		snapped(get_global_mouse_position().y - 8, 16)
	)
