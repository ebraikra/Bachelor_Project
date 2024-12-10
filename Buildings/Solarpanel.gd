class_name Solarpanel
extends Workstation

var has_needs_workers_been_called = false
var isPlaced = false

func _On_Day_Ended() -> void:
	pass

# Trick um das Problem zu lösen, dass Gebäude keine Energie geben können wenn sie 0 Workers haben
func NeedsWorkers() -> bool:
	if !has_needs_workers_been_called:
		has_needs_workers_been_called = true  
		return false
	return true

func IsAlreadyPlaced():
	if !isPlaced:
		isPlaced = true
		return false
	return true
