extends Node2D


#Connecten von Signalen
func _ready() -> void:
	GlobalSignals.NewDayStarted.connect(_On_NewDay_Started)
	GlobalSignals.DayEnded.connect(_On_Day_Ended)
	GlobalSignals.StartQuiz.connect(_On_Start_Quiz)
	GlobalSignals.EndQuiz.connect(_On_End_Quiz)
	RoundManager.RoundLost.connect(_On_RoundLost)
	RoundManager.RoundLostTree.connect(_On_RoundLostTree)

#Deaktiviert den "Neuer Tag" Button, um potentiellen Fehlern entgegen zu wirken
func _On_NewDay_Started() -> void:
	$CanvasLayer/Button.disabled = true

#Reaktiviert den "Neuer Tag" Button, so bald der Tag beendet ist
func _On_Day_Ended() -> void:
	$CanvasLayer/Button.disabled = false

#Zeigt die Verloren-Übersicht an
func _On_RoundLost() -> void:
	$CanvasLayer/LosePanel.show()
	
func _On_RoundLostTree() -> void:
	$CanvasLayer/LosePanel2.show()
	
func _On_Start_Quiz() -> void:
	await get_tree().create_timer(0.5).timeout # Benötigt damit das vorherige Signal den Button nicht direkt wieder überschreibt.
	$CanvasLayer/Button.disabled = true
	
func _On_End_Quiz() -> void:
	await get_tree().create_timer(0.5).timeout
	$CanvasLayer/Button.disabled = false
	
#Sorgt dafür, das Gebäude an das Spielgitter "gesnapped" werden
func _unhandled_input(event: InputEvent) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	$Camera2D/Indicator.global_position = Vector2(
		snapped(get_global_mouse_position().x - 8, 16),
		snapped(get_global_mouse_position().y - 8, 16)
	)
