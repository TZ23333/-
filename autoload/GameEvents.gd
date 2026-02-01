extends CardManager
class_name GameEvents

signal card_played(card_instance: card, target_zone: String)
signal card_discard(card_instance: card)
signal turn_ended
signal turn_started
signal game_over(result: String)
signal excess_hand_cards(excess_count: int)
