extends Control

#Logik für das Quiz

@onready var questionLabel = $Panel/MarginContainer/VBoxContainer/Questions
@onready var answerList = $Panel/MarginContainer/VBoxContainer/AnswerList
@onready var button = $Panel/MarginContainer/VBoxContainer/Button
@onready var checkButton = $Panel/MarginContainer/VBoxContainer/CheckButton
@onready var hintText = $Panel/MarginContainer/VBoxContainer/Hinttext
@onready var nextDay = $"../Button"

var file
var questionsList: Array = read_json_file("Quiz/Questions.json")
var question: Dictionary
var indexQuestion: int = 0
var answerGiven: String

func _ready():
	hide()
	questionsList.shuffle()
	GlobalSignals.StartQuiz.connect(start_quiz)

func start_quiz():
	# zeigt keine Fragen mehr, wenn alle Fragen beantwortet worden sind
	if questionsList[indexQuestion] != null:
		show()
		show_question()
		nextDay.disabled = true

func show_question():
	answerList.show()
	checkButton.show()
	#answerList.clear() 
	question = questionsList[indexQuestion]
	questionLabel.text = question.TEXT
	var answers = question.OPTIONS
	answers.shuffle()
	for answer in answers:
		# Erstelle einen Button für die Antwort
		var button = Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Button soll sich horizontal anpassen
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # Vertikales Schrumpfen und Zentrieren
		button.flat = true  # Der Button sieht flach aus, ohne standardmäßiges Button-Design

		# Erstelle ein Label für den Text der Antwort
		var label = Label.new()
		label.text = answer

		# Aktiviert den Zeilenumbruch nach Wörtern
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		#label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Lässt das Label sich horizontal anpassen
		label.grow_horizontal = Control.GROW_DIRECTION_BOTH  # Lässt das Label nach beiden Seiten wachsen
		label.grow_vertical = Control.GROW_DIRECTION_BOTH  # Passt die Höhe dynamisch an den Text an

		# Füge das Label in den Button ein
		button.add_child(label)

		# Setze den Button so, dass er seine Größe dynamisch an den Inhalt (Label) anpasst
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		#button.rect_min_size = Vector2(0, 0)  # Sicherstellen, dass der Button keine Mindestgröße hat

		# Verbinde das Signal des Buttons
		button.connect("pressed", Callable(self, "_on_answer_button_pressed").bind(answer))

		# Füge den Button in die answerList (VBoxContainer) ein
		answerList.add_child(button)

		
		##Container erstellen um Text unter einem Button hinzufügen. Workaround fix damit der Text besser lesbar ist.
		#var answerContainer = VBoxContainer.new()
		#
		#var label = Label.new()
		#label.text = answer
		#label.autowrap_mode = TextServer.AUTOWRAP_WORD  # Aktiviert den automatischen Zeilenumbruch im Label. Die Funktion die es bei einer Auswahlliste leider nicht gibt
		##label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Lässt das Label sich horizontal anpassen  # Optional: Setzt eine Mindestgröße für das Label
		#
		## Erstelle einen Button, der den Text enthält und klickbar ist
		#var button = Button.new()
		#button.text = ""  # Der Button hat keinen Text, er ist nur ein klickbarer Bereich
		##button.flat = true  # Entfernt die Umrandung des Buttons
		#button.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Passt sich horizontal an den Container an
		#button.size_flags_vertical = Control.SIZE_EXPAND_FILL  # Passt sich vertikal an den Container an
		#button.connect("pressed", Callable(self, "_on_answer_button_pressed").bind(answer))  # Verbinde das "pressed"-Signal
#
		## Füge das Label und den Button in den VBoxContainer ein
		#answerContainer.add_child(label)
		#answerContainer.add_child(button)
#
		## Füge den VBoxContainer in die answerList (VBoxContainer) ein
		#answerList.add_child(answerContainer)

		# Füge den VBoxContainer in die answerList (VBoxContainer) ein
		#answerList.add_child(container)
		#answerList.add_item(answer)
func _on_answer_button_pressed(answer: String):
	answerGiven = answer  # Speichere die ausgewählte Antwort
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
	if answerGiven == question.CORRECTANSWER:
		var random_float = randf()
		if random_float < 0.7:
			# 70% chance ist Niete
			hintText.text = question.CORRECTRIVET
		else:
			# 30% chance auf Buff
			hintText.text = question.CORRECTANSWERTEXT
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
	nextDay.disabled = false
	#TODO Buffs hinzufügen

func _on_check_button_pressed():
	check_answer()
	show_result()

#checkt welche antwort gegeben wurde
func _on_answer_list_item_selected(index):
	answerGiven = answerList.get_item_text(index)
