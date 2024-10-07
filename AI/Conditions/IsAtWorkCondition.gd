extends ConditionLeaf

#NPC-Verhaltensabfrage um zu prüfen, ob NPC auf Arbeit ist
func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.isAtWork == true:
		if actor.workplace.chimney:
			actor.workplace.chimney.show()
		elif actor.workplace is Windpower:
				actor.workplace.rotor.play("active")
		else:
			actor.workplace.pig_1.play("awake")
			actor.workplace.pig_2.play("awake")
		actor.hide()
		return SUCCESS
	return FAILURE
