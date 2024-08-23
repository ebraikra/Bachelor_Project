extends Node2D

#Codeleiche-------------------

#var curBuilding: Node2D :
	#set(val):
		#GlobalSignals.BuildingHover.emit(val)
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	#curBuilding = body
#
#func _on_area_2d_body_exited(body: Node2D) -> void:
	#curBuilding = null
