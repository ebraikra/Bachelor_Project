class_name Coalplant
extends Workstation

#Erweiterung der "Lumberjack/Workstation"-Klasse, die lediglich zusätzlich die Schweinchen-Animation abspielt
@onready var chimney2: AnimatedSprite2D = $Chimney2

func _On_Day_Ended() -> void:
	chimney.hide()
	chimney2.hide()
	SendWorkersHome()
