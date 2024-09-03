extends Node

#Signale die Global aufgerufen werden sollen können

signal BuildingPlaced
signal BuildingRemoved(building: Node2D)
signal NewDayStarted
signal DayEnded
signal BuildingHover
signal AddAnalysis
signal StartQuiz

#Vordefinierte Typen für die Analyse-Berichte
enum ANALYSE{
	TREE_NOT_SPAWNING,
	CLOUDS_SPAWNING
}
