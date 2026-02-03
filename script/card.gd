extends Control


var pickButton:Node
@onready var title = $Panel/ColorRect/Title
@onready var description = $Panel/ColorRect/description
@onready var table_zone: Area2D = $Camera2D/PanelContainer/CanvasLayer/CardZones/TableZone
@onready var icon: Sprite2D = $Panel/ColorRect/Icon


signal discard_card_a
signal discard_card_b

#卡牌信息变量
var CardName:String
var CardInfo:Dictionary
var CardClass:String
var CardSpecial:int
var instance_id:int = -1
# 卡牌数据
var card_instance = null
var card_data: Dictionary = {}

#卡牌运动变量
var stiffness = 500
var damping =0.35
var velocity = Vector2.ZERO

#卡牌状态枚举
enum cardState{following,dragging,using,RETURNING}
@export var cardCurrentState = cardState.following
@export var follow_target:Node
#debug变量
var Which_deck_mouse_in
var is_dragging: bool = false
var drag_offset: Vector2
var original_position: Vector2
var original_z_index: int
var original_parent: Node
var is_in_hand: bool = true
var is_playable: bool = true
var original_rotation: float
var zone

signal drag_started(card)
signal drag_ended(card, drop_zone)
signal card_dropped(card, zone)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = global_position
	original_rotation = rotation
	original_z_index = z_index
	original_parent = get_parent()
	pass # Replace with function body.

func _enter_tree() -> void:
	zone = $Camera2D/PanelContainer/CanvasLayer/CardZones/TableZone

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match cardCurrentState:
		cardState.dragging:
			var target_position = get_global_mouse_position()-size/3		
			global_position = global_position.lerp(target_position,0.4)

			var mouse_position = get_global_mouse_position()
			var nodes = get_tree().get_nodes_in_group("cardDropable")
			for node in nodes:
				if node.get_global_rect().has_point(mouse_position) && node.visible == true:
					Which_deck_mouse_in = node

		cardState.following:
			if follow_target != null:
				var target_position = follow_target.global_position
				var displayment = target_position - global_position
				var force = displayment * stiffness
				velocity += force * delta
				velocity *=(1.0 - damping)
				global_position += velocity * delta
	pass
	
func is_point_in_rect_area(point: Vector2, area: Area2D) -> bool:
	# 获取碰撞形状
	var collision_shape = area.get_node_or_null("CollisionShape2D")
	if not collision_shape or not collision_shape.shape is RectangleShape2D:
		return false
	
	# 计算矩形的全局边界
	var rect_extents = collision_shape.shape.extents
	var rect_position = area.global_position + collision_shape.position
	var rect = Rect2(rect_position - rect_extents, rect_extents * 2)
	
	return rect.has_point(point)


func _on_button_button_down() -> void:
	is_dragging = true
	original_position = self.global_position
	cardCurrentState = cardState.dragging
	Infos.selected_card_id =self.instance_id
	pass # Replace with function body.



func _on_button_button_up() -> void:
	is_dragging = false
	#检测放置区域
	var mpos = get_global_mouse_position()
	table_zone = get_node("/root/main/Camera2D/PanelContainer/CanvasLayer/CardZones/TableZone")
	if is_point_in_rect_area(mpos,table_zone):
		var emotion_sign = Infos.card_emotion.get(self.get_card_type())
		if abs(emotion_sign-Emotional.emotion_changeTo) in [0,2] and Infos.is_limit:
				handle_invalid_drop()
		else:
			Infos.is_card_discarded = true
			if Infos.selected_card_id == 0 or Infos.selected_card_id%2 == 0:
				discard_card_a.emit()
			else:
				discard_card_b.emit()
				
		#$"/root/Main/Card manager".discard.append()
			var tween = get_tree().create_tween()
			tween.tween_property(self,"global_position",Vector2(38,478),0.2)
	else:
		Infos.selected_card_id = 0
		Infos.is_card_discarded = false
	cardCurrentState = cardState.following
	pass # Replace with function body.
	
#func detect_drop_zones():
	##检测拖放区域
	#var drop_zones = get_tree().get_nodes_in_group("card_dropable")
	#var mouse_pos = get_global_mouse_position()
	#
	#Which_deck_mouse_in = null
	#var closest_zone = null
	#var closest_distance = 100000.0
	#for zone in drop_zones:
		#if not zone.visible:
			#continue
			#
		#if zone is Control:
			#var rect = Rect2(zone.global_position,zone.size)
			#if rect.has_point(mouse_pos):
				#var distance = zone.global_position.distance_to(mouse_pos)
				#if distance<closest_distance:
					#closest_distance = distance
					#closest_zone = zone
		#elif zone is Area2D:
			#var tween:Tween = get_tree().create_tween()
			#tween.tween_property(self,"global_position",Vector2(38,457),0.1)
			#var collision = zone.get_node_or_null("CollisionShape2D")
			#if collision and collision.shape is RectangleShape2D:
				#
				#if rect.has_point(mouse_pos):
					#var distance = zone.global_position.distance_to(mouse_pos)
					#if distance<closest_distance:
						#closest_distance = distance
						#closest_zone = zone
						
	
func detect_drop_zone()->String:
	if Which_deck_mouse_in == null:
		return "invalid"
		
	if Which_deck_mouse_in.has_method("get_zone_type"):
		return Which_deck_mouse_in.get_zone_type()
	elif Which_deck_mouse_in.is_in_group("deck"):
		return "deck"
	elif Which_deck_mouse_in.is_in_group("discard"):
		return "discard"
	else:
		return "invalid"

func handle_valid_drop(zone_type:String):
	print("卡牌放置到:",zone_type)
	
	match zone_type:
		"discard":
			card_dropped.emit(self,"discard")
			snap_to_zone(Which_deck_mouse_in)
			
func handle_invalid_drop():
	print("无效放置，返回原位置")
	cardCurrentState = cardState.RETURNING
	
	# 使用Tween实现平滑返回
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", original_position, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", original_rotation, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(_on_return_complete)
	
func _on_return_complete():
	# 返回原父节点
	var current_parent = get_parent()
	if current_parent != original_parent:
		current_parent.remove_child(self)
		original_parent.add_child(self)
		global_position = original_position
		z_index = original_z_index
	
	cardCurrentState = cardState.following
	print("卡牌返回原位置")

func snap_to_zone(zone_node: Node):
	# 快速移动到区域中心
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", zone_node.global_position, 0.2)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", 0.0, 0.2)

	tween.tween_callback(func():
		cardCurrentState = cardState.following
		)
		
func inital(card_inst):
	if not card_inst:
		push_error("初始化失败")
		return
		
	#保存卡牌实例
	card_instance = card_inst
	instance_id = card_inst.instance_id
	
	#获取卡牌数据
	card_data = card_inst.data
		
	update_card_display()
	
	print("卡牌节点初始化完成：",get_card_name())

#更新卡牌显示
func update_card_display():
	if card_data.is_empty():
		push_warning("卡牌数据为空")
		return
		
	#设置卡牌名称
	title = get_node("Panel/ColorRect/Title")	
	if title:
		var display_name = card_data.get("base_displayName","未知卡牌")
		title.text = display_name
		print("设置卡牌名称：",display_name)
		
	title = get_node("Panel/ColorRect/Title")	
	if description:
		var card_description = card_data.get("description","")
		description.text = card_description
		
	load_card_image()
		
func load_card_image():
	var imgPath ="res://Sprite/CardIcon/"+str(card_data.get("base_cardclass"))+".png"
	$Panel/ColorRect/Icon.texture = load(imgPath)

# 获取卡牌名称
func get_card_name() -> String:
	if card_data.is_empty():
		return "未知卡牌"
	return card_data.get("base_displayName", "未知卡牌")

# 获取卡牌类型
func get_card_type() -> String:
	if card_data.is_empty():
		return "unknown"
	return card_data.get("base_cardclass", "unknown")

func drawCard():
	pickButton = $Button
	var imgPath ="res://Sprite/CardIcon/"+str(CardName)+".png"
	$Panel/ColorRect/Img.texture = load(imgPath)
	$Panel/ColorRect/name.text = CardInfo["base_displayName"]
