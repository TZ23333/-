extends Panel

@onready var card_poidesk: HBoxContainer = $CardPoidesk
@onready var carddeck: Control = $Carddesk

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if carddeck.get_child_count() != 0:
		var children = carddeck.get_children()
		sort_node_by_position(children)
		
#排序的函数
func sort_node_by_position(children):
	children.sort_custom(sort_by_position)
	for i in range(children.size()):
		if children[i].cardCurrentState:
			children[i].z_index = 1
			carddeck.move_child(children[i],i)

#排序规则的函数
func sort_by_position(a,b):
	return a.position.x < b.position.x
	pass
	
func add_card(cardToAdd)->void:
	var index = cardToAdd.z_index
	var global_poi = cardToAdd.global_position 
	var cardBackground = preload("res://scene/card_background.tscn").instantiate()
	card_poidesk.add_child(cardBackground)
	#判断index层数关系
	if index <= card_poidesk.get_child_count():
		card_poidesk.move_child(cardBackground,index)
	else:
		card_poidesk.move_child(cardBackground,-1) 
		
	if cardToAdd.get_parent():
		cardToAdd.get_parent().remove_child(cardToAdd)
	carddeck.add_child(cardToAdd)
	cardToAdd.global_position = global_poi
	
	cardToAdd.follow_target = cardBackground
	
	cardToAdd.cardCurrentState = cardToAdd.cardState.following
