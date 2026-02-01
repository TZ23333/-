extends Node2D

@onready var tile_map_layer: TileMapLayer = $background/TileMapLayer
@onready var player: Control = $background/player
#@export var con : PackedScene
@onready var handzone: Control = $Camera2D/PanelContainer/CanvasLayer/CardZones/Handzone
@onready var doomtime: RichTextLabel = $Camera2D/PanelContainer/CanvasLayer/Doomtime

signal moveing(usedcell : Array[Vector2i],chik : InputEvent)
signal talk(chik : InputEvent)

var Used_Cell : Array[Vector2i]
var now_position : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	handzone.visible = false
	doomtime.visible = false
	for cell in tile_map_layer.get_used_cells():
		if tile_map_layer.get_cell_tile_data(cell).get_custom_data("able"):
			Used_Cell.append(cell)
			#var co = con.instantiate()
			#co.position = tile_map_layer.map_to_local(cell)
			#self.add_child(co)
			
	player.global_position = tile_map_layer.map_to_local(Used_Cell[0])
	
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		moveing.emit(Used_Cell,event)
		talk.emit(event)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	now_position = $background/TileMapLayer.local_to_map(player.position)
	if now_position == Vector2i(12,0):
		$background/player/Button2.show()
	else :
		$background/player/Button2.hide()
	
	if now_position == Vector2i(42,0):
		$background/player/Button3.show()
	else :
		$background/player/Button3.hide()
		
	if now_position == Vector2i(26,3):
		$background/player/Button4.show()
	else :
		$background/player/Button4.hide()
		
	if now_position == Vector2i(26,24):
		$background/player/Button5.show()
	else :
		$background/player/Button5.hide()


func _on_button_button_up() -> void:
	$Camera2D.hide()
	$background.show()
	handzone.visible = true
	doomtime.visible = true
	pass # Replace with function body.
