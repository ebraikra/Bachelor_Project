extends Node

#Manager für die einzelnen Rundenphasen, also in welcher Phase sich der Spieler gerade befindet,
#ob's das Intro ist, der Spieler gerade baut, die Runde veliert etc.

signal RoundLost

enum PHASES {
	INTRO,
	BUILD,
	EVENT,
	LOSEROUND,
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

#Codeleiche
func _PhaseBuild() -> void:
	pass
