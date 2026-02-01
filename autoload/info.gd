extends Node

var infosDic:Dictionary
var file_path = "res://Asset/Cardinfos.csv"
var current_deck:Array[String] = [
	"happy_1","happy_2","happy_3",
	"angry_1","angry_2","angry_3",
	"sad_1","sad_2","sad_3",
	"scare_1","scare_2","scare_3"
]
# 运行时卡牌实例存储
var card_instances: Dictionary = {}  # instance_id -> 卡牌实例字典
var next_instance_id: int = 0
	
func _init() -> void:
	infosDic = read_csv_as_nested_dict(file_path)
	print("Info单例初始化完毕，加载了",infosDic.size(),"张卡牌数据")
	

#函数读取csv文件并转化为嵌套字典
func read_csv_as_nested_dict(path:String)->Dictionary:
	var data = {}
	var file = FileAccess.open(path,FileAccess.READ)
	var headers = []
	var first_line = true
	while not file.eof_reached():
		var values = file.get_csv_line()
		if first_line:
			headers = values
			first_line = false
		elif values.size()>=2:
			var key = values[0]
			var row_dict = {}
			for i in range(0,headers.size()):
				row_dict[headers[i]] = values[i]
			data [key] = row_dict
	file.close()
	return data
	
func get_card_data(card_id:String) -> Dictionary:
	return infosDic.get(card_id,{})

# 获取卡牌实例
func get_card_instance(instance_id: int) -> Dictionary:
	return card_instances.get(instance_id, {})

# 创建卡牌实例
func create_card_instance(card_id: String) -> Dictionary:
	var card_data = get_card_data(card_id)
	if card_data.is_empty():
		print("错误: 卡牌ID不存在: ", card_id)
		return {}
	
	var instance_id = get_next_instance_id()
	
	var card_instance = {
		"instance_id": instance_id,
		"card_id": card_id,
		"data": card_data,
	"zone": "deck"
	}
	
	card_instances[instance_id] = card_instance
	return card_instance

# 获取下一个实例ID
func get_next_instance_id() -> int:
	var id = next_instance_id
	next_instance_id += 1
	return id

#获取当前卡组
func get_current_decK() -> Array[String]:
	return current_deck.duplicate()
