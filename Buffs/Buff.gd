extends Object

class_name Buff

var type: String
var value: float  # Der Prozentwert des Buffs 
#var duration: float  # Dauer in Sekunden, wie lange der Buff aktiv ist

func _init(_type: String, _value: float):
	self.type = _type
	self.value = _value
#duration = _duration # Optional
	# Called when the node enters the scene tree for the first time.
