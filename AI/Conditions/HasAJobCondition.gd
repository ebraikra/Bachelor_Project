extends ConditionLeaf

#NPC-Verhaltensabfrage um zu prüfen, ob NPC eine Arbeit hat
func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.GetWorkplace() != null:
		return SUCCESS
	return FAILURE

