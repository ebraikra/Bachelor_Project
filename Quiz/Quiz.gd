extends Control

#Logik für das Quiz

@onready var questionLabel = $Panel/MarginContainer/VBoxContainer/Questions
@onready var answerList = $Panel/MarginContainer/VBoxContainer/AnswerList
@onready var button = $Panel/MarginContainer/VBoxContainer/Button
@onready var checkButton = $Panel/MarginContainer/VBoxContainer/CheckButton
@onready var hintText = $Panel/MarginContainer/VBoxContainer/Hinttext

var file
var questionsList: Array = read_json_file("Quiz/Questions.json")
var question: Dictionary
var indexQuestion: int = 0
var correctAnswer: int = 0
var answerGiven: int = 0

func _ready():
	hide()
	GlobalSignals.StartQuiz.connect(start_quiz)

func start_quiz():
	if questionsList[indexQuestion] != null:
		show()
		show_question()

func show_question():
	answerList.show()
	checkButton.show()
	answerList.clear() 
	question = questionsList[indexQuestion]
	questionLabel.text = question.TEXT
	var answers = question.OPTIONS
	for answer in answers:
		answerList.add_item(answer)

	
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

#Überprüft die Antworten und zieht die Texte von der json auf die Nodes, damit die sichtbar werden
func check_answer():
	correctAnswer = question.CORRECTINDEX
	if answerGiven == correctAnswer:
		hintText.text = question.CORRECTANSWER #TODO Random funktion ob niete oder nicht
	else:
		hintText.text = question.WRONGANSWER
		
func show_result():
	answerList.hide()
	checkButton.hide()
	button.show()
	hintText.show()
	
#Schließt das Quizfenster
func _on_button_pressed():
	hide()
	hintText.hide()
	indexQuestion += 1
	button.hide()
	#TODO Buffs hinzufügen

func _on_check_button_pressed():
	check_answer()
	show_result()

#checkt welche antwort gegeben wurde
func _on_answer_list_item_selected(index):
	answerGiven = index
