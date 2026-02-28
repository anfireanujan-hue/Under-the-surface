extends Node
@onready var scorelabel: Label = $scorelabel

var score  = 0
func add_point():
	score += 1
	scorelabel.text = "you collected " + str(score) + " coins,,"
	
	
	 
