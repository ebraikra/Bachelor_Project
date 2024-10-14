extends ConditionLeaf

#NPC-Verhaltensabfrage um zu prüfen, ob NPC auf Arbeit ist
func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.isAtWork == true:
		if actor.workplace is Coalplant:
			actor.workplace.chimney.show()
			actor.workplace.chimney2.show()
		elif actor.workplace is Windpower:
				actor.workplace.rotor.play("active")
		elif actor.workplace is Plantfarm:
				actor.workplace.farmer_1.show()
				actor.workplace.farmer_2.show()
				actor.workplace.farmer_3.show()
				actor.workplace.farmer_4.show()
				actor.workplace.farmer_1.play("work")
				actor.workplace.farmer_2.play("work")
				actor.workplace.farmer_3.play("work")
				actor.workplace.farmer_4.play("work")
		elif actor.workplace is Pigfarm:
			actor.workplace.pig_1.play("awake")
			actor.workplace.pig_2.play("awake")
		actor.hide()
		return SUCCESS
	return FAILURE
