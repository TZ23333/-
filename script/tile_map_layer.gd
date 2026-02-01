extends TileMapLayer
const PLLLLAYER = preload("res://scenc/pllllayer.tscn")

@onready var main: Node2D = $"../.."
@onready var player: Control = $"../player"
@onready var pllllayer: Control = $"../pllllayer"
@onready var camera_2d: Camera2D = $"../../Camera2D"
@onready var label: Label = $"../player/Label"
@onready var canvas_layer: CanvasLayer = $"../../Camera2D/PanelContainer/CanvasLayer"
@onready var walk_sound: AudioStreamPlayer = $walk_sound

signal happy_trigger
signal sad_trigger
signal scare_trigger



const happy_tile_coords:Vector2i = Vector2i(2,2)
const angry_tile_coords:Vector2i = Vector2i(9,2)
const sad_tile_coords:Vector2i = Vector2i(9,8)
const scare_tile_coords_a:Vector2i = Vector2i(2,6)
const scare_tile_coords_b:Vector2i = Vector2i(33,38)
var new_tile_coords:Vector2i
var old_tile_coords:Vector2i

var move_distance:int = 1

var moveing := Vector2i.ZERO
var mos = 3
var ui_time := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main.moveing.connect(self.moveto)
	canvas_layer.ui_ing.connect(self.isui)
	var ic = PLLLLAYER.instantiate()
	ic.global_position = self.map_to_local(Vector2i(12,0))
	self.add_child(ic)
	
	var ic1 = PLLLLAYER.instantiate()
	ic1.global_position = self.map_to_local(Vector2i(42,0))
	self.add_child(ic1)

	var ic2 = PLLLLAYER.instantiate()
	ic2.global_position = self.map_to_local(Vector2i(26,3))
	self.add_child(ic2)
	
	var ic3 = PLLLLAYER.instantiate()
	ic3.global_position = self.map_to_local(Vector2i(26,24))
	self.add_child(ic3)

func moveto(usedcell:Array[Vector2i],event:InputEvent):
	if event is not InputEventMouseButton:
		return	
	
	var e := event as InputEventMouseButton
	if e.button_index == MOUSE_BUTTON_RIGHT and e.pressed:
		pllllayer.hide()
		moveing = Vector2i.ZERO
	
	if e.button_index != MOUSE_BUTTON_LEFT or !e.pressed:
		return
	
	if ui_time:
		return
	
	var moto = camera_2d.get_global_mouse_position()
	var cell = self.local_to_map(moto)
	print(cell)
	if cell == self.local_to_map(player.global_position):
		return
	
	if !usedcell.has(cell):
		return
	
	var ab = self.get_cell_tile_data(cell)
	if ab.get_custom_data("able"):
		var moll = cell - self.local_to_map(player.position)
		if moll.length() > move_distance:
			pllllayer.hide()
			moveing = Vector2i.ZERO
			return
			
		if mos < 1 :
			pllllayer.hide()
			moveing = Vector2i.ZERO
			return
		
		if moveing == Vector2i.ZERO:
			pllllayer.global_position = self.map_to_local(cell)
			pllllayer.show()
			moveing = cell
		elif cell == moveing:
			match Emotional.emotion_changeTo:
				0:
					replace_tile_before(4,happy_tile_coords)
				1:
					replace_tile_before(4,angry_tile_coords)
				2:
					replace_tile_before(4,sad_tile_coords)
				3:
					replace_tile_before(4,scare_tile_coords_a)
					
			player.global_position = self.map_to_local(cell)
			mos -= 1
			walk_sound.play()
			check_tile_effect(self.local_to_map(player.position))
			pllllayer.hide()
			moveing = Vector2i.ZERO
		else :
			pllllayer.position = self.map_to_local(cell)
			pllllayer.show()
			moveing = cell

func replace_tile_before(soure_id:int,new_tile_coords):
		old_tile_coords = self.local_to_map(player.position)
		var spe = self.get_cell_tile_data(old_tile_coords)
		if spe.get_custom_data("special_effect") == 0:
			set_cell(old_tile_coords,4,new_tile_coords,0)
		
func check_tile_effect(cell_position:Vector2i):
		var spe = self.get_cell_tile_data(cell_position)
		match spe.get_custom_data("special_effect"):
			2:
				mos -= 2
			3:
				scare_trigger.emit()
			4:
				happy_trigger.emit()
		
	
	
	
	
func isui(ui_ing : bool):
	ui_time = ui_ing
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(mos)
	if Infos.vectory_sign < 5:
		camera_2d.global_position = player.global_position
	if mos <= 0:
		mos = 0
	if move_distance <=1:
		move_distance = 1
	pass

func _on_card_manager_card_played_2() -> void:
	mos += 2
	pass # Replace with function body.


func _on_card_manager_card_played_3() -> void:
	mos += 3
	pass # Replace with function body.


func _on_card_manager_card_played_1() -> void:
	mos += 1
	pass # Replace with function body.

func _on_test_1_button_down() -> void:
	move_distance += 1
	pass # Replace with function body.


func _on_test_2_button_down() -> void:
	move_distance -= 1
	pass # Replace with function body.
