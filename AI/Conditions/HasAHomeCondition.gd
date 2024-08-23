extends ConditionLeaf

#NPC-Verhaltensabfrage um zu prüfen, ob NPC in einem Haus wohnt
func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.home != null:
		return SUCCESS
	return FAILURE

