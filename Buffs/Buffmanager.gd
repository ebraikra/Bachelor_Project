extends Node

var active_buffs = {}

# Hinzufügen eines Buffs
func apply_buff(type: String, buff_value: float) -> void:
	if type in active_buffs:
		active_buffs[type].value += buff_value
	else:
		active_buffs[type] = Buff.new(type, buff_value)
	print("Buff applied: ", type, " Value: ", buff_value)

# Abrufen des Buffs
func get_buff_value(type: String) -> float:
	if type in active_buffs:
		return active_buffs[type].value
	return 0.0
