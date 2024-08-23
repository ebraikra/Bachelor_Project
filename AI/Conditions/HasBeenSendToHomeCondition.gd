extends ConditionLeaf

#NPC-Verhaltensabfrage um zu prüfen, ob NPC nach Hause geschickt wurde
func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.hasBeenSendToHome:
		return SUCCESS
	return FAILURE

