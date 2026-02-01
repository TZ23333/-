extends Node2D
class_name CardManager

signal card_drawn(card)
signal card_discarded(card)
signal deck_shuffled
signal hand_updated
signal card_played_2
signal card_played_3

@export var card_scene: PackedScene
@export var hand_card_spacing: float = 120.0
@export var hand_curve_height: float = 30.0

@onready var card_poidesk: HBoxContainer = $"../CardZones/Handzone/CardPoidesk"

var selected_card:card
class card:
	var instance_id: int
	var card_id: String
	var card_name: String
	var card_type: String
	var description: String
	var mana_cost: int
	var data:Dictionary

	func _init(id: int,card_data: Dictionary):
		instance_id = id
		data = card_data
		card_id = card_data.get("id","")
		card_name = card_data.get("base_displayName","未知卡牌")
		card_type = card_data.get("base_cardclass","emotion")
		description = card_data.get("base_description","")
	func has(property:String) -> bool:
		return data.has(property)
		
		
#牌桌数组
var deckcard:Array[card] = []
var handcard:Array[card] = []
var discard:Array[card] = []

var deck_card_ids: Array[String] = []       # 牌库中的卡牌ID列表
var hand_instance_ids: Array[int] = []      # 手牌中的卡牌实例ID列表
var discard_instance_ids: Array[int] = []   # 弃牌堆中的卡牌实例ID列表

#相邻情绪记录枢
var first_discard:String
var second_discard:String
var is_first:bool = true

#计数器
var card_counter:int = 0
var card_nodes:Dictionary = {} #id

func initialize_current_deck() -> bool:
	print("初始化卡组")
	clear_all_zones()
	
	var deck_ids = Info.get_current_decK()
	
	if deck_ids.is_empty():
		push_error("卡组为空！")
		return false
		
	print("加载卡组，包含",deck_ids.size(),"张卡牌")
	
	for card_id in deck_ids:
		var card_data = Info.get_card_data(card_id)
		
		if card_data:
			var card_instance = card.new(card_counter,card_data)
			card_counter += 1
			deckcard.append(card_instance)
			
			print("添加卡牌：",card_instance.card_name)
		else:
			print("警告：卡牌ID",card_id,"不存在，跳过")
	shuffle_deck()
	updata_ui()
	return true

func clear_all_zones():
	deckcard.clear()
	handcard.clear()
	discard.clear()
	# 清除所有视觉节点
	for card_node in card_nodes.values():
		if is_instance_valid(card_node):
			card_node.queue_free()
	card_nodes.clear()
	
	card_counter = 0
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if has_node("/root/GameEvent"):
		var game_event = get_node("/root/GameEvent")
		if game_event.has_signal("card_played"):
			game_event.card_played.connect(_on_card_played)
		if game_event.has_signal("card_discarded"):
			game_event.card_discarded.connect(_on_card_discarded)
	pass # Replace with function body.
	

func _on_card_played(card):
	print("卡牌打出: ", card)

func _on_card_discarded(card):
	print("卡牌弃掉: ", card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Infos.is_card_discarded:
		for c in handcard:
			if c.instance_id == Infos.selected_card_id:
				discard.append(c)
				is_double(c)
				handcard.erase(c)
				hand_instance_ids.erase(c)
				remove_card_visual(c)
				Infos.is_card_discarded = false
				if c.instance_id%2 == 1:
					card_played_2.emit()
				else:
					card_played_3.emit()
	pass

#判断是否对偶
func is_double(c:card)-> void:
	if is_first:
		first_discard = c.card_type
		is_first = false
	else:
		second_discard = c.card_type
		is_first = true
	if first_discard == second_discard:
		draw_card(2)
		first_discard == null
		second_discard == null
		is_first = true
		Infos.is_turn_end = false

func intialize_deck(card_data_list:Array[Dictionary]):
	deckcard.clear()
	card_counter = 0
	for card_data in card_data_list:
		var card_instance = card.new(card_counter,card_data)
		card_counter += 1
		deckcard.append(card_instance)
	
	shuffle_deck()
	updata_ui()
	
#洗牌
func shuffle_deck():
	deckcard.shuffle()
	deck_shuffled.emit()
	print("牌库已洗牌，剩余%d张"% deckcard.size())

#抽牌
func draw_card(count:int = 1)->bool:
	if deckcard.is_empty():
		print("牌库为空")
		if Infos.is_turn_end == true:
			for i in discard:
				deckcard.append(i)
			shuffle_deck()
			discard.clear()
		
	for i in range(count):
		if deckcard.is_empty():
			break
		var drawn_card = deckcard.pop_front()
		hand_instance_ids.append(drawn_card.instance_id)
		handcard.append(drawn_card)
		create_card_visual(drawn_card)
		card_drawn.emit(drawn_card)
		
	update_hand_layout()
	updata_ui()
	return true
	
#弃牌
func discard_card(card_instance:card,from_zone:String = "hand")->bool:
	#从原区域移除
	match from_zone:
		"hand":
			if not hand_instance_ids.has(card_instance):
				return false
			hand_instance_ids.erase(card_instance)
			remove_card_visual(card_instance)
		"played":
			remove_card_visual(card_instance)
	
	#添加到弃牌堆
	discard.append(card_instance)
	card_discarded.emit(card_discarded)	
	
	update_hand_layout()
	updata_ui()
	return true

#创建卡牌视觉节点
func create_card_visual(card_instance:card):
	if not card_scene:
		push_error("卡牌预制体未设置")
		return
	
	var card_node = card_scene.instantiate()
	if not card_node.has_method("inital"):
		push_error("卡牌节点没有initialize方法")
		return
		
	card_node.inital(card_instance)
	card_nodes[card_instance.instance_id] = card_node
	
	var hand_zone = get_node_or_null("../CardZones/Handzone")
	if hand_zone:
		card_poidesk = $"../CardZones/Handzone/CardPoidesk"
		card_poidesk.add_child(card_node)
		card_node.position = Vector2(150,447)
		
#移除卡牌视觉节点
func remove_card_visual(card_instance:card):
	var card_node = card_nodes.get(card_instance.instance_id)
	if card_node:
		card_node.queue_free()
		card_nodes.erase(card_instance.instance_id)
		
#更新手牌布局
func update_hand_layout():
	var hand_zone = get_node_or_null("../CardZones/Handzone")
	if not hand_zone:
		return
		
	var card_count = hand_instance_ids.size()
	var center_index = card_count/2.0
	
	for i in handcard:
		var card_instance = i
		var card_node = card_nodes.get(card_instance.instance_id)
		if not card_node:
			continue
		
func updata_ui():
	var ui = get_node_or_null("../UI")
	if ui:
		if ui.has_method("update_deck_count"):
			ui.update_deck_count(deckcard.size())
		if ui.has_method("update_discard_count"):
			ui.update_discard_count(discard.size())
		if ui.has_method("update_hand_count"):
			ui.updata_hand_count(handcard.size())
			
	hand_updated.emit()
	
func get_card_instance(instance_id:int) -> card:
	for card in handcard + deckcard + discard:
		if card.instance_id == instance_id:
			return card
	return null


func _on_tile_map_layer_happy_trigger() -> void:
	Infos.is_turn_end = false
	draw_card(2)
	pass # Replace with function body.
