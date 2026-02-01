extends Node2D

@onready var tile_map_layer: TileMapLayer = $background/TileMapLayer
@onready var player: Control = $background/player
#@export var con : PackedScene
@onready var handzone: Control = $Camera2D/PanelContainer/CanvasLayer/CardZones/Handzone
@onready var doomtime: RichTextLabel = $Camera2D/PanelContainer/CanvasLayer/Doomtime
@onready var background: Node2D = $background
@onready var panel_container: PanelContainer = $Camera2D/PanelContainer/CanvasLayer/PanelContainer
@onready var label: Label = $Camera2D/PanelContainer/CanvasLayer/Label
@onready var camera_2d: Camera2D = $Camera2D
@onready var test_1: Button = $background/player/Test1
@onready var test_2: Button = $background/player/Test2
@onready var bgm: AudioStreamPlayer2D = $BGM
@onready var control: Control = $background/player/Control
@onready var control_2: Control = $background/player/Control2
@onready var control_4: Control = $background/player/Control4
@onready var control_3: Control = $background/player/Control3
@onready var canvas_layer: CanvasLayer = $Camera2D/PanelContainer/CanvasLayer
@onready var 情绪状态: Sprite2D = $Camera2D/PanelContainer/CanvasLayer/情绪状态

signal moveing(usedcell : Array[Vector2i],chik : InputEvent)
signal talk(chik : InputEvent)

var Used_Cell : Array[Vector2i]
var now_position : Vector2i


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	handzone.visible = false
	doomtime.visible = false
	background.visible = false
	panel_container.visible = false
	label.visible = false
	camera_2d.zoom = Vector2(5,5)
	test_1.visible = false
	test_2.visible = false
	doomtime.visible = false
	情绪状态.visible = false
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
	control.global_position = player.global_position + Vector2(Vector2i(12,0)-now_position).normalized() * 10
	control_2.global_position = player.global_position + Vector2(Vector2i(42,0)-now_position).normalized() * 10
	control_3.global_position = player.global_position + Vector2(Vector2i(26,3)-now_position).normalized() * 10
	control_4.global_position = player.global_position + Vector2(Vector2i(26,24)-now_position).normalized() * 10
	if now_position == Vector2i(12,0):
		$background/player/Button2.show()
		$background/player/Button2.global_position = $background/player.global_position
	else :
		$background/player/Button2.hide()
	
	if now_position == Vector2i(42,0):
		$background/player/Button3.show()
		$background/player/Button3.global_position = $background/player.global_position
	else :
		$background/player/Button3.hide()
		
	if now_position == Vector2i(26,3):
		$background/player/Button4.show()
		$background/player/Button4.global_position = $background/player.global_position
	else :
		$background/player/Button4.hide()
		
	if now_position == Vector2i(26,24):
		$background/player/Button5.show()
		$background/player/Button5.global_position = $background/player.global_position
	else :
		$background/player/Button5.hide()
		
	if $Camera2D/PanelContainer/CanvasLayer.ui_time == false and Infos.vectory_sign == 5:
		play_ending_new()
	if Infos.doom_time <= 0:
		doomtime.text = "游戏结束！"
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://main.tscn")
		
func play_ending_new():
	$background/player.remove_child(camera_2d)
	self.add_child(camera_2d)
	canvas_layer.visible = false
	var tween:Tween = get_tree().create_tween().set_parallel()
	tween.tween_property(camera_2d,"zoom",Vector2(0.765,0.765),3.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera_2d,"global_position",Vector2(541.36,248.28),3.0).set_ease(Tween.EASE_OUT)
	camera_2d.global_position = Vector2(541.36,248.28)
	Infos.vectory_sign += 1
	


func _on_button_button_up() -> void:
	$Camera2D.hide()
	$background.show()
	handzone.visible = true
	doomtime.visible = true
	情绪状态.visible = true
	bgm.play()
	pass # Replace with function body.


func _on_reset_button_down() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	pass # Replace with function body.


func _on_bgm_finished() -> void:
	bgm.play()
	pass # Replace with function body.
