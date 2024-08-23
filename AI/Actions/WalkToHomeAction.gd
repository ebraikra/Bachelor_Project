extends ActionLeaf

#NPC-Verhalten um NPC nach Hause zu schicken
#Wenn das Verhalten aufgerufen wird, wird der "IstAufArbeit"-Status aus False gesetzt, die Geschwindigkeit berechnet die es braucht um zeitgleich alle Aliens
#zu deren Wohnort zu schicken.
#Funktion wird pro Tick, also pro Frame ausgelöst. NPC wird so lang Richtung Haus bewegt bis
#NPC in der Nähe des eigenen Hauses ist und der Status "IstZuhause" auf True gesetzt wird
func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.isAtWork = false
	actor.velocity = (actor.position.direction_to(actor.home.position) ) * actor.position.distance_to(actor.home.position) * 0.03 * actor.speed
	if actor.position.distance_to(actor.home.position) < 10:
		actor.isAtHome = true
		return SUCCESS
	actor.show()
	actor.move_and_slide()
	return RUNNING

