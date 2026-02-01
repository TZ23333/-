extends CanvasLayer
signal ui_ing(uiing : bool)

const BUTTON = preload("uid://ccla7blv7g4v5")

var index = 0
var ui_time := false
var DILOGS : Resource
@onready var main: Node2D = $"../../.."
@onready var doomtime: RichTextLabel = $Doomtime


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



func _on_button_3_button_up() -> void:
	$Label.show()
	ui_ing.emit(true)
	ui_time = true
	DILOGS = load("res://resource/2_dilogs.tres")



func _on_button_4_button_up() -> void:
	$Label.show()
	ui_ing.emit(true)
	ui_time = true
	DILOGS = load("res://resource/3_dilogs.tres")



func _on_button_5_button_up() -> void:
	$Label.show()
	ui_ing.emit(true)
	ui_time = true
	DILOGS = load("res://resource/4_dilogs.tres")



func _on_button_6_button_up() -> void:
	$Label.show()
	ui_ing.emit(true)
	ui_time = true
	DILOGS = load("res://resource/5_dilogs.tres")



func _on_button_7_button_up() -> void:
	$Label.show()
	ui_ing.emit(true)
	ui_time = true
	DILOGS = load("res://resource/6_dilogs.tres")

func _process(delta: float) -> void:
	doomtime.text = str(Infos.doom_time)
