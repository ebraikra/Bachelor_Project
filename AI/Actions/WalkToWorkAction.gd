extends ActionLeaf

#NPC-Verhalten um NPC zur Arbeit zu schicken
#Wenn das Verhalten aufgerufen wird, wird der "IstZuhause"-Status aus False gesetzt, die Geschwindigkeit berechnet die es braucht um zeitgleich alle Aliens
#zu deren Arbeit zu schicken.
#Funktion wird pro Tick, also pro Frame ausgelöst. NPC wird so lang Richtung Arbeit bewegt bis
#NPC in der Nähe der Arbeit ist und der Status "IstAufArbeit" auf True gesetzt wird
func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.isAtHome = false
	actor.velocity = (actor.position.direction_to(actor.workplace.position) ) * actor.position.distance_to(actor.workplace.position) * 0.03 * actor.speed
	if actor.position.distance_to(actor.workplace.position) < 10:
		actor.isAtWork = true
		return SUCCESS
	actor.show()
	actor.move_and_slide()
	return RUNNING
