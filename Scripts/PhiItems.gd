extends Node

signal speed_improvement
signal unlock_phi_item
signal lock_phi_item
signal show_phi_spent

onready var Player = $"%Player"
onready var Milestones = $"%Player/Milestones"
onready var Counters = $"%Player/Counters"


var phi_spent = Big.new(0)


var items = {
	"AddFifthCounter": {"lvl": 0, "price": 1},
	"AddSixthCounter": {"lvl": 0, "price": 5},
	"ImproveSpeed": {"lvl": 0, "price": 15},
	"BetterSixthCounter": {"lvl": 0, "price": 30},
}


func _ready():
	Player.phi.connect("phi_changed", self, "_on_phi_changed")
	Player.phi.connect("phi_spent", self, "_on_phi_spent")


func _on_phi_spent(n):
	print("phi spent now", n)
	phi_spent = phi_spent.plus(n)
	print("phi spent total", phi_spent)
	emit_signal("show_phi_spent", str(phi_spent))
	unlock_items()
	if items.BetterSixthCounter.lvl < 0:
		var capped = Big.max(phi_spent, Big.new(940))
		Counters.Counter6.efficiency = capped.minus(40).sqrt().round_down() 
		# phi_spent 41 -> 1, 45 -> 2, 80 -> 6, 100 -> 7, 140 -> 10, 440 -> 20, 940 -> 30 
	

func _on_phi_changed(_data):
	for key in items:
		if items[key].lvl >= 0: # only if not bought (bought and locked are set to -1)
			if Player.phi.gte(items[key].price):
				print("unlock", key)
				emit_signal("unlock_phi_item", key)
			else:
				print("lock", key)
				emit_signal("lock_phi_item", key)

func unlock_items():
	print("unlocking phi items: phi spent: ", phi_spent)
	if phi_spent.gte(1):
		Milestones.unlock("first_phi_unlock")
		Counters.Counter1.efficiency = 1.5
	if phi_spent.gte(10):
		Milestones.unlock("second_phi_unlock")
		Counters.Counter2.efficiency = 1.5
	if phi_spent.gte(20):
		Milestones.unlock("third_phi_unlock")
		Counters.Counter1.efficiency = 2
	if phi_spent.gte(50):
		Milestones.unlock("fourth_phi_unlock")
		Counters.Counter3.efficiency = 1.5
	if phi_spent.gte(80):
		Milestones.unlock("fifth_phi_unlock")
		Counters.Counter4.efficiency = 1.5


func tick_speed():
	return pow(1.2, items.ImproveSpeed.lvl)


func save():
	var data = {
		"Node": "PhiItems",
		"items": items,
		"phi_spent": phi_spent.serialize()
	}
	return data
	
	
func load(data):
	items = data.items
	phi_spent.restore(data.phi_spent)
	
	emit_signal("speed_improvement", [items.ImproveSpeed.lvl, items.ImproveSpeed.price])
	emit_signal("show_phi_spent", str(phi_spent))
	


func _on_AddFifthCounter_pressed():
	
	if Player.phi.gte(items.AddFifthCounter.price):
		Player.phi.spend(items.AddFifthCounter.price)
		items.AddFifthCounter.lvl = -1
		Milestones.unlock("counter_5_available")


func _on_AddSixthCounter_pressed():
	if Player.phi.gte(items.AddSixthCounter.price):
		Player.phi.spend(items.AddSixthCounter.price)
		items.AddSixthCounter.lvl = -1
		Milestones.unlock("counter_6_available")


func _on_ImproveSpeed_pressed():
	if Player.phi.gte(items.ImproveSpeed.price):
		Player.phi.spend(items.ImproveSpeed.price)
		items.ImproveSpeed.lvl += 1
		items.ImproveSpeed.price = pow(2, items.ImproveSpeed.lvl) * 15
		Counters.set_tick_speed(tick_speed())
		emit_signal("speed_improvement", [items.ImproveSpeed.lvl, items.ImproveSpeed.price])


func _on_BetterSixthCounter_pressed():
	if Player.phi.gte(items.BetterSixthCounter.price):
		Player.phi.spend(items.BetterSixthCounter.price)
		items.BetterSixthCounter.lvl = -1
		var capped = Big.max(phi_spent, Big.new(940))
		Counters.Counter6.efficiency = capped.minus(40).sqrt().round_down() 
		Milestones.unlock("improved_counter_6")




func reset(): # when phi is reset on infinity
	Counters.set_tick_speed(1)
