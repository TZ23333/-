extends CanvasLayer
signal ui_ing(uiing : bool)

const BUTTON = preload("uid://ccla7blv7g4v5")

var index = 0
var ui_time := false
var DILOGS : Resource
@onready var main: Node2D = $"../../.."
@onready var doomtime: RichTextLabel = $Doomtime
@onready var button_2: Button = $"../../../background/player/Button2"
@onready var button_3: Button = $"../../../background/player/Button3"
@onready var button_4: Button = $"../../../background/player/Button4"
@onready var button_5: Button = $"../../../background/player/Button5"
@onready var camera_2d: Camera2D = $"../.."
@onready var 新手教程2: RichTextLabel = $新手教程2
@onready var 新手教程: Sprite2D = $新手教程
@onready var control: Control = $"../../../background/player/Control"
@onready var control_2: Control = $"../../../background/player/Control2"
@onready var control_3: Control = $"../../../background/player/Control3"
@onready var control_4: Control = $"../../../background/player/Control4"
@onready var 距离: Label = $距离


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main.talk.connect(self.contin)
	pass # Replace with function body.



func contin(event : InputEvent):

	if !ui_time	:
		return
	
	if event is not InputEventMouseButton or !event.is_pressed():
		return
	$Label.text = ""
	for i in $PanelContainer/VBoxContainer.get_children():
		i.queue_free()
	continiu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func chois(next:int):
	index = next
	continiu()
	for i in $PanelContainer/VBoxContainer.get_children():
		i.queue_free()
	$PanelContainer.hide()

func continiu():
	if index > len(DILOGS._dilogs) - 1:
		ui_time = false
		ui_ing.emit(false)
		$Label.hide()
		index = 0
		return
	var dil = DILOGS._dilogs[index]
	$Label.text = dil.text
	
	if !dil.chs:
		index = dil.next
		return
	
	$PanelContainer.show()
	for i in len(dil.chss):
		var c = dil.chss[i]
		var butt = BUTTON.instantiate()
		butt.text = c.qus
		butt.next = c.next
		$PanelContainer/VBoxContainer.add_child(butt)
		butt._next.connect(self.chois)

func _on_button_2_button_up() -> void:
	$Label.show()
	ui_ing.emit(true)
	ui_time = true
	DILOGS = load("res://resource/1_dilogs.tres")
	Infos.vectory_sign += 1
	button_2.disabled = true
	control.visible = false



func _on_button_3_button_up() -> void:
	$Label.show()
	ui_ing.emit(true)
	ui_time = true
	DILOGS = load("res://resource/2_dilogs.tres")
	Infos.vectory_sign += 1
	button_3.disabled = true
	control_2.visible = false

func _on_button_4_button_up() -> void:
	$Label.show()
	ui_ing.emit(true)
	ui_time = true
	DILOGS = load("res://resource/3_dilogs.tres")
	Infos.vectory_sign += 1
	button_4.disabled = true
	control_3.visible = false
	
	
func _on_button_5_button_up() -> void:
	$Label.show()
	ui_ing.emit(true)
	ui_time = true
	DILOGS = load("res://resource/4_dilogs.tres")
	Infos.vectory_sign += 1
	button_5.disabled = true
	control_4.visible = false


func _process(delta: float) -> void:
	doomtime.text = "剩余回合：" + str(Infos.doom_time)
	if ui_time:
		$CardZones.hide()
	else :
		$CardZones.show()
	if ui_time == false and Infos.vectory_sign == 4:
		play_ending()


#结局
func play_ending():
	$Label.show()
	ui_ing.emit(true)
	ui_time = true
	DILOGS = load("res://resource/6_dilogs.tres")
	Infos.vectory_sign = 5
	pass # Replace with function body.



func _on_button_button_up() -> void:
	$Label.show()
	新手教程.visible = false
	新手教程2.visible = false
	doomtime.visible = true
	ui_ing.emit(true)
	ui_time = true
	距离.text = "移动距离：" + str(Infos.move_distance)
	DILOGS = load("res://resource/5_dilogs.tres")
	pass # Replace with function body.
