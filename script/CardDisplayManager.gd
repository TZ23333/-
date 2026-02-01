extends Node
class_name CardDisplayManager

@onready var card_img = $Panel/ColorRect/Img
@onready var card_name_label = $Panel/ColorRect/name
@onready var pick_button = $Button
@onready var highlight_effect = $Panel/Highlight

var current_card_info: Dictionary = {}
var current_instance_id: int = -1
var is_active: bool = true

func _ready():
	if pick_button:
		pick_button.pressed.coonect(_on_pick_button_pressed)
	#初始隐藏
	self.visible = false
	
func initialize_card_display(card_key:String) -> bool:
	if not Info.infosDic.has(card_key):
		return false
	current_card_info = Info.infosDic[card_key]
	draw_card_visual()
	self.visible = true
	return true
	
#通过实例id初始化
func initialize_from_instance(instance_id:int) ->bool:
	var card_instance = Info.get_card_instance(instance_id)
	if card_instance.is_empty():
		return false
		
	current_instance_id = instance_id
	current_card_info = card_instance.get("data",{})
	
	draw_card_visual()
	self.visible = true
	
	return true
	
func draw_card_visual():
	if not card_img or not card_name_label:
		return
		
	var card_name = current_card_info.get("base_card","")
	var img_path = "res://Sprite/CardIcon"+str(card_name)+".png"
	var texture = load(img_path)
	
	if texture:
		card_img.texture = texture
	else:
		card_img.texture = preload("res://Sprite/CardIcon/default.png")
		print("使用默认图片:",card_name)
		
	var display_name = current_card_info.get("base_displayName","未知卡牌")
	card_name_label.text = display_name
	
	#卡牌类型
	var card_class = current_card_info.get("type","未知")

		
func _on_pick_button_pressed():
	print("卡牌被选中：",current_card_info.get("base_displayName",""))
	
	card_selected.emit(current_instance_id,current_card_info)
	
signal card_selected(instance_id: int, card_info: Dictionary)
