extends Camera2D

#Codeleiche--------------------------------------------------------------

#const DEAD_ZONE = 300
#
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#var _target = event.position - get_viewport().size * 0.5
		#if _target.length() < DEAD_ZONE:
			#self.position = Vector2(0, 0)
		#else:
			#self.position = _target.normalized() * (_target.length() - DEAD_ZONE) * 0.5
