extends Node

signal update_counter_buttons
signal update_PB

onready var Player = $"%Player"
onready var Milestones = $"%Player/Milestones"

export (Resource) var Counter1
export (Resource) var Counter2
export (Resource) var Counter3
export (Resource) var Counter4
export (Resource) var Counter5
export (Resource) var Counter6


func _ready():
	Counter1.set("10", "1e3", "Counter2")
	Counter2.set("100", "1e4", "Counter3")
	Counter3.set("1e4", "1e5", "Counter4")
	Counter4.set("1e6", "1e6", "Counter5")
	Counter5.set("1e9", "1e8", "Counter6")
	Counter6.set("1e13", "1e18")


func reset():
	Counter1.reset()
	Counter2.reset()
	Counter3.reset()
	Counter4.reset()
	Counter5.reset()
	Counter6.reset()
	update_button()


func buy_counter(item, qty := 1):
	var price = self[item].price()
	if Player.alpha.gte(price):
		Player.alpha.spend(price)
		self[item].add_lvl(qty)

		update_button(item)
		
	if Counter1.gte(1) and !Milestones.is_unlocked("counter_1_bought"):
		Milestones.unlock("counter_1_bought")
		
	if Counter1.gte(10) and !Milestones.is_unlocked("counter_2_available"):
		Milestones.unlock("counter_2_available")

	if Counter2.gte(10) and !Milestones.is_unlocked("counter_3_available"):
		Milestones.unlock("counter_3_available")
		
	if Counter3.gte(10) and !Milestones.is_unlocked("counter_4_available"):
		Milestones.unlock("counter_4_available")

	if Counter4.gte(20) and !Milestones.is_unlocked("sacrifice_alpha_available"):
		Milestones.unlock("sacrifice_alpha_available")


func update_button(item = null):
	var array = ["Counter1", "Counter2", "Counter3", "Counter4", "Counter5", "Counter6"]
	if item: # hack so we can update one item only if we wish
		array = [item, ]
	for item in array:
		var provider = self[item].provider
		var qty = self[item].qty
		var percent = null
		if provider:
			if qty.gt(0):
				var output = self[provider].output()
				percent = str(output.divide(qty).multiply(100))
			else:
				percent = "0"
		var signal_content = {
				"id": item, 
				"qty": str(self[item].qty), 
				"price": str(self[item].price()),
				"multiplier": str(self[item].multiplier()),
				"percent": percent
		}
		emit_signal("update_counter_buttons", signal_content)
		emit_signal("update_PB", [item, self[item].lvl % 10])


func set_tick_speed(speed, counter = false):
	if counter:
		counter = [counter, ]
	else:
		counter = ["Counter1", "Counter2", "Counter3", "Counter4", "Counter5", "Counter6"]

	for key in counter:
		self[key].tick_speed = speed


func save():
	var data = {
		"Node": "Counters",
		"Counter1": Counter1.serialize(),
		"Counter2": Counter2.serialize(),
		"Counter3": Counter3.serialize(),
		"Counter4": Counter4.serialize(),
		"Counter5": Counter5.serialize(),
		"Counter6": Counter6.serialize(),
	}
	return data


func load(data):
	Counter1.restore(data.Counter1)
	Counter2.restore(data.Counter2)
	Counter3.restore(data.Counter3)
	Counter4.restore(data.Counter4)
	Counter5.restore(data.Counter5)
	Counter6.restore(data.Counter6)

