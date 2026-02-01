extends Node2D

enum emotion{happy,angry,sad,scare}
var emotion_sign_num
var emotion_change:Array[int]
var emotion_changeTo:int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emotion_sign_num = Infos.doom_time
	emotion_change = [0,1,2,3]
	emotion_changeTo = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if emotion_sign_num != Infos.doom_time:
		change_emotion()
		emotion_sign_num = Infos.doom_time
	pass

func change_emotion():
	if emotion_changeTo in range(0,3):
		emotion_changeTo +=1
	else:
		emotion_changeTo = 0
	print(emotion_changeTo)
	
