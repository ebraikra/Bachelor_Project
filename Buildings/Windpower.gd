class_name Windpower
extends Workstation

#Erweiterung der "Lumberjack/Workstation"-Klasse, die lediglich zusätzlich die Schweinchen-Animation abspielt

@onready var rotor: AnimatedSprite2D = $Rotor


func _On_Day_Ended() -> void:
	#rotor.stop()
	SendWorkersHome()
