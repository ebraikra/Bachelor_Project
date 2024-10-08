extends TileMap

#Logik für die ganzen Bäume auf der Karte
#Dient dazu den Spawnwert der Bäume je nach CO2 Wert anzupassen, sobald ein Tag endet
#Sorgt ebenfalls dafür, dass die Bäume visuell auf dem Spielfeld erscheinen bzw. entfernt werden

@onready var GrowTimer: Timer = $"../Timer"
var treeSpawnRate: int = 10
var allTrees: Array
var hasBeenNotified: bool = false
var alreadyAnalysed: bool = false

#Testzwecke
#var woodneed: int = 15

func _ready() -> void:
	GlobalSignals.DayEnded.connect(_On_Day_Ended)

#Prüft, ob die Baum Spawnrate größer 0 ist, wenn ja wird geschaut wo Bäume spawnen können
#Hier wurde festgelegt, das Bäume nur an bereits bestehenden Bäumen weiterwachsen dürfen und das Feld frei sein muss
func _On_Day_Ended() -> void:
	adjust_wood_based_on_co2()
	var treeCounter: int = 0
	if treeSpawnRate >= 0:
		while treeCounter < treeSpawnRate:
			var tree: Vector2i = GetAllEndings().pick_random()
			var freeCells: Array = []
			for cell: Vector2i in get_surrounding_cells(tree):
				if get_cell_tile_data(1, cell) == null:
					freeCells.append(cell)
			if !freeCells.is_empty():
				get_surrounding_cells(tree)
				var rand: int = randi_range(0, get_surrounding_cells(tree).size() - 1)
				set_cell(1, freeCells.pick_random(), 0, Vector2i(8, 7))
				treeCounter += 1
	else:
		while treeCounter > treeSpawnRate:
			if GetAllEndings().is_empty():
				RoundManager.StartPhase(RoundManager.PHASES.LOSEROUNDTREE)
				return
			var tree: Vector2i = GetAllEndings().pick_random()
			set_cell(1, tree, 0, Vector2i(0, 1))
			treeCounter -= 1

func delete_trees_on_produced_wood(woodneed, treeCounter) -> void:
	while woodneed > treeCounter:
		if GetAllEndings().is_empty():
			RoundManager.StartPhase(RoundManager.PHASES.LOSEROUNDTREE)
			return
		var tree: Vector2i = GetAllEndings().pick_random()
		set_cell(1, tree, 0, Vector2i(0, 1))
		treeCounter += 1
		#print("deleted trees", treeCounter)

#Passt den Spawnwert der Bäume an den CO2 Wert an, ähnlich wie bei den Wolken im Smogfilter "Cloudparticles.gd"
func adjust_wood_based_on_co2() -> void:
	var ranges: Array = [range(0, 99), range(100, 400), range(400, 500), range(501, 600), range(601, 1000)]
	for i: Array in ranges:
		if i.has(%ColonyService.co2):
			match ranges.find(i):
				0:
					treeSpawnRate = 10
				1:
					treeSpawnRate = 5
				2:
					treeSpawnRate = 0
				3:
					treeSpawnRate = -5
				4:
					treeSpawnRate = -10
	#Fügt die Analyse "Es wachsen keine Bäume mehr nach", sobald der Spawnwert der Bäume <=0 ist und diese
	#Analyse noch nicht berichtet wurde
	if treeSpawnRate <= 0:
		if !alreadyAnalysed: 
			GlobalSignals.AddAnalysis.emit(GlobalSignals.ANALYSE.TREE_NOT_SPAWNING)
			alreadyAnalysed = true
			%AlienScientist.play("analysis_bad")
		%Backgroundmusic.stop()
		if !%BackgroundmusicChanged.playing:
			%BackgroundmusicChanged.play()
	else:
		%BackgroundmusicChanged.stop()
		if !%Backgroundmusic.playing:
			%Backgroundmusic.play()

#Rückgabe aller "Enden" eines Waldes, also nur die äußersten Bäume werden returned
func GetAllEndings() -> Array:
	var tileArr: Array = []
	for cell in get_used_cells(1):
		if get_cell_tile_data(1, cell).get_custom_data_by_layer_id(0):
			tileArr.append(cell)
	return tileArr

#Rückgabe aller Bäume
func GetAllTrees() -> Array:
	return get_used_cells(1)
	
