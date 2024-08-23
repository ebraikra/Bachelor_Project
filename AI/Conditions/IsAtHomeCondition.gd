extends ConditionLeaf

#NPC-Verhaltensabfrage um zu prüfen, ob NPC Zuhause ist
func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.isAtHome == true:
		actor.hide()
		return SUCCESS
	return FAILURE

