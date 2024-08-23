class_name Pigfarm
extends Workstation

#Erweiterung der "Lumberjack/Workstation"-Klasse, die lediglich zusätzlich die Schweinchen-Animation abspielt

@onready var pig_1: AnimatedSprite2D = $Pig1
@onready var pig_2: AnimatedSprite2D = $Pig2


func _On_Day_Ended() -> void:
	pig_1.play("sleep")
	pig_2.play("sleep")
	SendWorkersHome()
