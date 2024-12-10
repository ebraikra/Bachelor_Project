class_name Plantfarm
extends Workstation

#Erweiterung der "Lumberjack/Workstation"-Klasse, die lediglich zusätzlich die Schweinchen-Animation abspielt

@onready var farmer_1: AnimatedSprite2D = $Farmer1
@onready var farmer_2: AnimatedSprite2D = $Farmer2
@onready var farmer_3: AnimatedSprite2D = $Farmer3
@onready var farmer_4: AnimatedSprite2D = $Farmer4


func _On_Day_Ended() -> void:
	farmer_1.stop()
	farmer_1.hide()
	farmer_2.stop()
	farmer_2.hide()
	farmer_3.stop()
	farmer_3.hide()
	farmer_4.stop()
	farmer_4.hide()
	SendWorkersHome()
