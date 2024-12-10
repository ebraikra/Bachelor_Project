extends Node

#Manager für die einzelnen Rundenphasen, also in welcher Phase sich der Spieler gerade befindet,
#ob's das Intro ist, der Spieler gerade baut, die Runde veliert etc.

signal RoundLost
signal RoundLostTree
signal RoundWon

enum PHASES {
	INTRO,
	BUILD,
	EVENT,
	LOSEROUND,
	LOSEROUNDTREE,
	ROUNDWON,
	OUTRO
}

#Startet einer der Phasen aus PHASES
func StartPhase(phase: PHASES) -> void:
	match phase:
		#Codeleiche
		PHASES.BUILD:
			_PhaseBuild()
		PHASES.LOSEROUND:
			RoundLost.emit()
		PHASES.LOSEROUNDTREE:
			RoundLostTree.emit()
		PHASES.ROUNDWON:
			RoundWon.emit()

#Codeleiche
func _PhaseBuild() -> void:
	pass
