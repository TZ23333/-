extends CanvasLayer

var selected_card_id:int = 0
var is_card_discarded:bool = false
var card_emotion:Dictionary = {
	"喜":0,
	"怒":1,
	"哀":2,
	"惧":3
}
var doom_time = 15
var is_turn_end = false

func add_new_card(cardName,carddesk,caller=get_tree().get_first_node_in_group("cardDeck"))->Node:
	print("开始创建新卡牌："+str(cardName))
	var cardClass = Info.infosDic[cardName]["base_cardclass"]
	print("添加卡的类型是%s:"%cardClass)
	var cardToAdd
	
	cardToAdd = preload("res://scene/card.tscn").instantiate()
	
	cardToAdd.inital(cardName)
	
	cardToAdd.global_position = caller.global_position  #令卡牌从caller处移动到牌桌deck
	carddesk.add_card(cardToAdd)
	return cardToAdd
