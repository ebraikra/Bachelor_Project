extends ConditionLeaf

#NPC-Verhaltensabfrage um zu prüfen, ob NPC zur Arbeit geschickt wurde
func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.hasBeenSendToWork:
		return SUCCESS
	return FAILURE

