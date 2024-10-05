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


var file
var questionsList: Array = read_json_file("Quiz/Questions.json")
var question: Dictionary
var indexQuestion: int = 0
var answerGiven: String
var active_buffs = {}

func _ready():
	hide()
	questionsList.shuffle() # würfelt die Fragen nach dem Neustart des Spiels
	GlobalSignals.StartQuiz.connect(_start_quiz)

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
	if answerGiven == question.CORRECTANSWER:
		var random_float = randf()
		if random_float < 0.01:
			# 1% chance auf besondere Belohnung
			buff_manager.apply_buff(buff_type, 3)
			alienScientist.play("quiz_speak")
			questionLabel.text = "Unglaublich! Die Bevölkerung sieht es genauso und ist sich einig. Die Produktion wird sehr stark ansteigen"
		elif random_float < 0.71:
			# 70% chance ist Niete
			alienScientist.play("quiz_neutral")
			questionLabel.text = question.CORRECTRIVET
		else:
			# 30% chance auf Buff
			buff_manager.apply_buff(buff_type, buff_value)
			alienScientist.play("analysis_friendly")
			questionLabel.text = question.CORRECTANSWERTEXT
	else:
			buff_manager.apply_buff(buff_type, debuff_value)
			alienScientist.play("quiz_neutral")
			questionLabel.text = question.WRONGANSWER 
			
		
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
	GlobalSignals.EndQuiz.emit()
	#TODO Buffs hinzufügen

func _on_check_button_pressed():
	if !answerGiven.is_empty():
		alienScientist.stop()
		check_answer()
		show_result()
