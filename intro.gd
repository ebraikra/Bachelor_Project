extends Control

@onready var alienScientist = $Panel/MarginContainer/VBoxContainer/Control/AlienScientist
@onready var text = $Panel/MarginContainer/VBoxContainer/Textfield/Text
@onready var label = $Panel/MarginContainer/VBoxContainer/Label

var index = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	alienScientist.play("quiz_friendly")


func _on_button_pressed():
	text.text = ""
	index += 1
	match index:
		1:
			text.text = "Solange die Versorgung gewährleistet ist, wächst die Bevölkerung. Baue zunächst Häuser, damit wir arbeiten können. Die findest du unter MISC"
			alienScientist.play("quiz_speak")
		2:
			text.text = "Es gibt noch Gebäude für Essen, Energie und Holzgewinnung. Da wir nur effizente Verbrenner-Techniken haben, müssen wir erstmal damit klarkommen. "
			alienScientist.play("analysis_neutral")
		3:
			text.text = "Baue Farmen für die Essensgewinnung, Kohlekraftwerke für die Energiegewinnung und Holzfäller, um Rohstoffe für weitere Gebäude zu gewinnen. Wenn die Zeit weiter voranschreitet, haben wir auch umweltfreundlichere Alternativen. Unsere Wissenschaftler arbeiten auf Hochtouren."
			alienScientist.play("quiz_neutral")
		4:
			text.text = "Achte darauf, dass du nicht zu viel Holz abbaust, ansonsten könnte das dem Ökosystem schaden. Platziere die Gebäude weise und achte darauf, das Gleichgewicht zu erhalten, bis wir mehrere Alternativen haben."
			alienScientist.play("analysis_bad")
		5:
			text.text = "Ziel ist es, deine Zivilisation wieder auf 100 Aliens wachsen zu lassen und dabei ein ökologisches Gleichgewicht zu erhalten. Dafür stehen dir verschiedene Gebäude im unteren Baumenü zur Verfügung."
			alienScientist.play("quiz_neutral")
		6:
			label.text = "Tutorial"
			text.text = "Das Raumschiff hat zu Beginn 2x Aliens, die automatisch Häusern zugewiesen werden, sobald ein Haus platziert wird. Das Raumschiff stellt mit jedem neuen Tag ein neues Alien bereit. Sollte kein Wohnplatz verfügbar sein, werden die Bewohner im Raumschiff gesammelt (Anzahl in der Anzeige darüber sichtbar)."
			alienScientist.play("quiz_speak")
		7:
			text.text = "Produktionsgebäude dienen als Arbeitsstelle für Aliens und sobald ein Produktionsgebäude über genügend Arbeiter verfügt, produziert dieses Rohstoffe."
			alienScientist.play("quiz_speak")
		8:
			text.text = "Beim Bau der Gebäude ist darauf zu achten, dass Aliens nach der Baureihenfolge zugeordnet werden."
			alienScientist.play("analysis_neutral")
		9:
			text.text = "Gebäude benötigen für den Bau Holz und zur Produktion Energie. Produktionsgebäude stoßen CO2 aus, welches, abhängig von der Anzahl, wiederum von Bäumen reduziert werden kann."
			alienScientist.play("quiz_speak")
		10:
			text.text = "Zudem benötigt ein Alien pro Tag 1 Nahrung."
			alienScientist.play("analysis_neutral")
		11:
			text.text = "Dann will ich nicht weiter stören, sobald wir neues haben und nochmal Infos von dir brauchen, melden wir uns nochmal. Viel Erfolg bei der Koordination und bis später"
			alienScientist.play("quiz_speak")
		12:
			hide()
	print(index)

func _on_skip_button_pressed() -> void:
	hide()
