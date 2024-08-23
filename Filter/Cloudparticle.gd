extends GPUParticles2D

#Partikelscript um die Smogwolken zu simulieren

var max_particles: int = 1000  # Maximale Anzahl von Partikeln, wenn CO2 hoch ist
var min_rate: int = 10  # Minimale Rate, wenn CO2 niedrig ist
var max_rate: int = 100  # Maximale Rate, wenn CO2 hoch ist
var alreadyAnalysed: bool = false
@onready var greyFilter: ColorRect = %GreyFilter

#Wird aufgerufen, um dem Filter mitzuteilen wenn sich der CO2 Wert ändert
#Sorgt dafür, dass je nachdem wie hoch der CO2 Wert ist, dieser mit der "ranges" Variable abgeglichen wird
#und je nachdem in welcher "Range" sich dieser befindet, die Dichte der Wolken, sowie der "Graufilter" Effekt
#erhöht wird
func update_co2(co2_value: int) -> void:
	var ranges: Array = [range(0, 99), range(100, 199), range(200, 299), range(300, 399), range(400, 499)]
	for i: Array in ranges:
		if i.has(co2_value):
			#Lernzielrelevant
			#Prüft, ob das Event bereits vorher eingetroffen ist, wenn nicht, wird am Ende des Tages erstmals
			#im Analyse-Bericht davon berichtet, dass Smogwolken auftauchen
			if !alreadyAnalysed: 
				GlobalSignals.AddAnalysis.emit(GlobalSignals.ANALYSE.CLOUDS_SPAWNING)
				alreadyAnalysed = true
			match ranges.find(i):
				0:
					var tween: Tween = get_tree().create_tween()
					tween.tween_property(self, "amount_ratio", 0.01, 1)
					tween.tween_property(greyFilter, "color", Color(greyFilter.color.r, greyFilter.color.g, greyFilter.color.b, 0), 1)
				1:
					var tween: Tween = get_tree().create_tween()
					tween.tween_property(self, "amount_ratio", 0.05, 1)
					tween.tween_property(greyFilter, "color", Color(greyFilter.color.r, greyFilter.color.g, greyFilter.color.b, 0.05), 1)
				2:
					var tween: Tween = get_tree().create_tween()
					tween.tween_property(self, "amount_ratio", 0.1, 1)
					tween.tween_property(greyFilter, "color", Color(greyFilter.color.r, greyFilter.color.g, greyFilter.color.b, 0.1), 1)
				3:
					var tween: Tween = get_tree().create_tween()
					tween.tween_property(self, "amount_ratio", 0.4, 1)
					tween.tween_property(greyFilter, "color", Color(greyFilter.color.r, greyFilter.color.g, greyFilter.color.b, 0.4), 1)
				4:
					var tween: Tween = get_tree().create_tween()
					tween.tween_property(self, "amount_ratio", 1, 1)
					tween.tween_property(greyFilter, "color", Color(greyFilter.color.r, greyFilter.color.g, greyFilter.color.b, 0.8), 1)

#Setzt die Startpositionen der Wolken
func _process(_delta: float) -> void:
	var screen_height: float = get_viewport_rect().size.y
	position.y = randf_range(0, screen_height)
