extends Control

#Logik für das Quiz

@onready var questionLabel = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Questions
@onready var answerList = $Panel/MarginContainer/VBoxContainer/AnswerList
@onready var button = $Panel/MarginContainer/VBoxContainer/Button
@onready var checkButton = $Panel/MarginContainer/VBoxContainer/CheckButton
@onready var hintText = $Panel/MarginContainer/VBoxContainer/Hinttext
@onready var nextDay = $CanvasLayer/Button
@onready var buff_manager = %Buffmanager
@onready var alienScientist = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Control/AlienScientist
@onready var colony_service = %ColonyService


var file
var questionsList: Array = read_json_file("Quiz/Questions.json")
var question: Dictionary
var indexQuestion: int = 0
var answerGiven: String
var active_buffs = {}
var infoAboutBuffsGiven = false

var solarpanel_data = preload("res://Data/Buildings/Buildings/Solarpanel.tres")
var windpower_data = preload("res://Data/Buildings/Buildings/Windpower.tres")
var plantfarm_data = preload("res://Data/Buildings/Buildings/Plantfarm.tres")

func _ready():
	hide()
	questionsList.shuffle() # würfelt die Fragen nach dem Neustart des Spiels
	GlobalSignals.StartQuiz.connect(_start_quiz)
	reset_to_original_value()

func _start_quiz():
	if indexQuestion < questionsList.size(): # zeigt keine Fragen mehr, wenn alle Fragen beantwortet worden sind
		if get_question(indexQuestion) != null :
			show()
			show_question()

func show_question():
	answerGiven = "" # Löscht die gegebenen Antworten, damit der Spieler nicht ausversehen eine falsche antwort gibt
	answerList.show()
	checkButton.show()
	question = get_question(indexQuestion)
	questionLabel.text = question.TEXT
	var answers = question.OPTIONS
	answers.shuffle()
	for answer in answers:
		# Button Erstellung für die Antworten. Workaround fix damit der Text besser lesbar ist.
		var answerButton = Button.new()
		#answerButton.flat = true  # Entfernt die Umrandung des Buttons
		answerButton.text = answer
		answerButton.autowrap_mode = TextServer.AUTOWRAP_WORD  # Aktiviert den automatischen Zeilenumbruch im Button. Die Funktion die es bei einer Auswahlliste leider nicht gibt
		answerButton.connect("pressed", Callable(self, "_on_answerbutton_pressed").bind(answer))
		answerList.add_child(answerButton)  # Fügt den Button zum VBoxContainer hinzu
		# Anpassungen am Container
		answerButton.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
		answerButton.size_flags_vertical = Control.SIZE_EXPAND_FILL  
	alienScientist.play("quiz_speak")

# Speichert die ausgewählte Antwort
func _on_answerbutton_pressed(answer: String):
	answerGiven = answer

func read_json_file(filename: String) -> Array:
	var file = FileAccess.open(filename, FileAccess.READ)
	if file == null:
		print("Error: Unable to open file:", filename)
		return []
	# Parse JSON data
	var json_data = JSON.parse_string(file.get_as_text())
	if typeof(json_data) == TYPE_DICTIONARY:
		if json_data.error != OK:
			print("Error parsing JSON: ", json_data.error_string())
			return []
		return json_data.result
	elif typeof(json_data) == TYPE_ARRAY:
		return json_data
	else:
		print("Unexpected JSON format.")
		return []

# Überprüft die Antworten und zieht die Texte von der json auf die Nodes, damit die sichtbar werden
func check_answer():
	var buff_type = question.BUFF
	var buff_value = question.BUFFVALUE
	var debuff_value = question.DEBUFFVALUE
	var applied_buff = false
	if answerGiven == question.CORRECTANSWER:
		var random_float = randf()
		if random_float < 0.01:
			# 1% chance auf besondere Belohnung
			if buff_type == "CO2":
				applied_buff = buff_manager.apply_buff(buff_type, -1)
				questionLabel.text = "Woa! Das scheint sehr gut zu funktionieren. Scheint so als wäre kaum noch CO2 mehr in der Atmosphäre"
			else:
				applied_buff = buff_manager.apply_buff(buff_type, 3)
				alienScientist.play("quiz_speak")
				questionLabel.text = "Unglaublich! Manchmal braucht man nur ein bisschen Glück und dann läuft alles von alleine"
		elif random_float < 0.61:
			# 70% chance ist Niete
			alienScientist.play("quiz_neutral")
			questionLabel.text = question.CORRECTRIVET
		else:
			# 30% chance auf Buff
			applied_buff = buff_manager.apply_buff(buff_type, buff_value)
			alienScientist.play("quiz_friendly")
			questionLabel.text = question.CORRECTANSWERTEXT
	else:
			applied_buff = buff_manager.apply_buff(buff_type, debuff_value)
			alienScientist.play("quiz_neutral")
			questionLabel.text = question.WRONGANSWER 
			
	if buff_type == "ENERGY":
		if applied_buff:
			var changeEnergy = colony_service.getEnergy()
			changeEnergy += changeEnergy * buff_manager.get_buff_value("ENERGY")
			print("changeEnergy:", changeEnergy)
			colony_service.setEnergy(changeEnergy)
	#Nur Upgrades
	if buff_type == "UPGRADEENERGY":
		if applied_buff:
			var upgrade_renewable_energy = buff_manager.get_buff_value("UPGRADEENERGY")
			windpower_data.produces[0] += windpower_data.produces[0] * upgrade_renewable_energy
			solarpanel_data.produces[0] += solarpanel_data.produces[0] * upgrade_renewable_energy
	if buff_type == "UPGRADEFOOD":
		if applied_buff:
			var upgrade_plant_farm = buff_manager.get_buff_value("UPGRADEFOOD")
			plantfarm_data.produces[1] += plantfarm_data.produces[1] * upgrade_plant_farm
		
func show_result():
	answerList.hide()
	for child in answerList.get_children():
		child.queue_free()
	checkButton.hide()
	button.show()
	#hintText.show()

# Zieht eine Frage aus dem aktuellen index
func get_question(indexQuestion):
	return questionsList[indexQuestion]

# Schließt das Quizfenster
func _on_button_pressed():
	hide()
	hintText.hide()
	indexQuestion += 1
	button.hide()
	if infoAboutBuffsGiven == false:
		%Intro.show()
		%Text.text = "Es wurde ein Buff hinzugefügt. Für jede richtig beantwortete Frage gibt es passende Verbesserungen. Die erscheinen jeweils unter den Ressourcen. Falsch beantwortete Fragen verschlechtern die Werte. Hinweis: Treibhausgase, sind nicht direkt erkenntlich. Übrigends gibt es in seltenen Fällen eine besondere Belohnung. Vielleicht hast du Glück und erhälst einen Bonus!"
		$"../Intro/Panel/MarginContainer/VBoxContainer/Button".hide()
		$"../Intro/Panel/MarginContainer/VBoxContainer/Control/AlienScientist".play("quiz_friendly")
		infoAboutBuffsGiven = true
	GlobalSignals.EndQuiz.emit()

func _on_check_button_pressed():
	if !answerGiven.is_empty():
		alienScientist.stop()
		check_answer()
		show_result()
		
# Setzt den Produktionswert auf den Originalwert zurück
func reset_to_original_value():
	windpower_data.produces[0] = 5
	solarpanel_data.produces[0] = 3
	plantfarm_data.produces[1] = 15
