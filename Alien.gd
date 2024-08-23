class_name Alien
extends Node2D

#Logik für ein einzelnes Alien-NPC

var speed: int = 50
var home: Accommodation = null
var workplace : Workstation = null
var isAtHome : bool = false
var isAtWork : bool = false
var hasBeenSendToWork : bool = false
var hasBeenSendToHome : bool = false

#Schickt NPC nach Hause
func SendToHome() -> void:
	hasBeenSendToWork = false
	hasBeenSendToHome = true

#Schickt NPC zur Arbeit
func SendToWork() -> void:
	hasBeenSendToWork = true
	hasBeenSendToHome = false

func _ready() -> void:
	pass
	hide()

#Setzt den Wohnort eines NPCs
func SetHome(accommodation: Accommodation) -> void:
	home = accommodation

#Rückgabe in welchem Haus der NPC lebt
func GetHome() -> Accommodation:
	return home

#Setzt den Arbeitsplatz des NPCs
func SetWorkplace(_workplace: Workstation) -> void:
	workplace = _workplace

#Rückgabe wo der NPC arbeitet
func GetWorkplace() -> Workstation:
	return workplace
