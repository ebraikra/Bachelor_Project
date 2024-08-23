extends Control

#Logik für den Analysebericht

@onready var analyses = $Panel/MarginContainer/VBoxContainer/Analyses
var fileData
var toAnalyze: Array = []

func _ready():
	hide()
	GlobalSignals.AddAnalysis.connect(_On_AddAnalysis)
	#Die Infos für die einzelnen Analysen, also der Text, sind in einer JSON hinterlegt die hier geladen wird
	var file = FileAccess.open("res://AnalysisData.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	fileData = data

#Fügt eine Analyse dem Analysebericht hinzu, also bspw. Bäume wachsen nicht mehr
func _On_AddAnalysis(analysis) -> void:
	toAnalyze.append(analysis)

#Startet die Analyse
func StartNewAnalysis() -> void:
	if analyses.get_child_count() > 0:
		for child in analyses.get_children():
			child.queue_free()
	for analysis in toAnalyze:
		var textLabel = RichTextLabel.new()
		var sep = HSeparator.new()
		analyses.add_child(textLabel)
		analyses.add_child(sep)
		var data = str(GlobalSignals.ANALYSE.keys()[analysis])
		textLabel.set_text(fileData.get(data).TEXT)
		textLabel.fit_content = true
	show()

#Rückgabe, wie viele Analysen im Bericht sind
func getAnalysisCount() -> int:
	return toAnalyze.size()

#Schließt das Analysefenster
func _on_button_pressed():
	toAnalyze.clear()
	hide()
