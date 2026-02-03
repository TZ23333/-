extends Node
class_name GameManager

enum GamePhase{
	DRAW,
	MAIN,
	END
}
@onready var card_manager: CardManager = $"../Card manager"
@onready var card_display: CardDisplayManager = $"../CardDisplayManager"
@onready var ui: CanvasLayer = $"../UI"
@onready var 情绪状态: Sprite2D = $"../情绪状态"

@export var starting_mana: int = 1
@export var max_mana: int = 10
@export var starting_hand_size: int = 5



var current_turn: int = 1
var current_phase: GamePhase
var is_player_turn: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	setup_game()
	pass # Replace with function body.

func setup_game():
	#初始化卡牌管理器
	card_manager.initialize_current_deck()
	
	
	#连接卡牌显示信号
	card_display.card_selected.connect(_on_card_selected)
	
	#抽起始手牌
	await draw_starting_hand(3)
	
	#开始第一回合
	start_new_turn()
	load_image("喜")

func draw_starting_hand(count:int = 3):
	for i in range(count):
		var drawn = card_manager.draw_card(1)
		if drawn:
			var last_index = card_manager.hand_instance_ids.size()-1
			var instance_id = card_manager.hand_instance_ids[last_index]
			card_display.initialize_from_instance(instance_id)
			
			await get_tree().create_timer(0.5).timeout
			print("起始手牌抽取完毕。")

func start_new_turn():
	print("第",current_turn,"回合开始")
	Infos.is_turn_end = true
	#抽两张牌
	for i in range(2):
		if card_manager.draw_card(1):
			#显示抽到的卡牌
			var last_index = card_manager.hand_instance_ids.size() -1
			var instance_id = card_manager.hand_instance_ids[last_index]
			card_display.initialize_from_instance(instance_id)
		
	await get_tree().create_timer(0.5).timeout
	update_ui()
		
func _on_card_selected(instance_id:int,card_info:Dictionary):
	print("卡牌被选中：",card_info.get("base_displayName",""))
	
	#检查是否可以打出
	if not card_manager.can_play_card(instance_id):
		print("这张牌现在不能打出")
		return
		
	#打出卡牌
	var success = card_manager.play_card(instance_id)
	
	if success:
		print("卡牌打出成功")
		
		card_display.visible = false
		
		if card_manager.hand_instance_ids.size()>0:
			var next_instance_id = card_manager.hand_instance_ids[0]
			card_display.initialize_from_instance(next_instance_id)
			
		update_ui()
	
func update_ui():
	if ui and ui.has_method("update_turn_display"):
		ui.update_turn_display(current_turn)
		
func _input(event):
	if event.is_action_pressed("next_turn"):
			#测试：按N键结束回合
			end_current_turn()
			
func end_current_turn():
	print("第",current_turn,"回合结束")
	Infos.doom_time -= 1
	Infos.move_distance = 1
	Infos.is_limit = true
	match Emotional.emotion_changeTo+1:
		0:
			load_image("喜")
		1:
			load_image("怒")
		2:
			load_image("哀")
		3:
			load_image("惧")
		4:
			load_image("喜")
	is_player_turn = false
	current_turn += 1
	is_player_turn = true
	start_new_turn()
	
func load_image(str:String):
	var imgPath ="res://Sprite/CardIcon/"+str+".png"
	情绪状态.texture = load(imgPath)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
