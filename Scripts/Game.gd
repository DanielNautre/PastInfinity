extends Node

const Counter = preload("res://Scripts/lib/Counter.gd")

signal number_changed
signal update_PB
signal button_update
signal milestone_passed
signal time_passed
signal update_sacrifice_alpha_btn
signal phi_changed

# TODO should saves be handled in a GO ?
var savefile = "user://PastInfinity.save"
var save_version = 0

# Game Stages (unlocked)
var milestones= {
	"game_started": false,
	"counter1_available": false,
	"counter1_bought": false,
	"counter2_available": false,
	"counter3_available": false,
	"counter4_available": false,
	"sacrifice_alpha_available": false,
	"phishop_available": false,
}

# moneys
# TODO move wallet to a node ??
var wallet = {
	"alpha": Big.new(0),
	"phi": Big.new(0)
}

# items
# TODO move counters to a node ??
var counters = {
	"Counter1": Counter.new("10", "1e3", "Counter2"),
	"Counter2": Counter.new("100", "1e4", "Counter3"),
	"Counter3": Counter.new("1e4", "1e5", "Counter4"),
	"Counter4": Counter.new("1e6", "1e6", "Counter5"),
	"Counter5": Counter.new("1e9", "1e8", "Counter6"),
	"Counter6": Counter.new("1e13", "1e18"),
}

var phi_items = {
	"fifth_counter": false
}

var stats = {
	"time_since_start": 0,
	"number_clicked": 0,
	"alpha_spent": Big.new(0),
	"phi_spent": Big.new(0),
}

var achievements = {
	"why": false
}


func _ready():
	# try to load the previous save
	load_game()
	unlock_milestones(true)


func _notification(what):
	# save the game on quit
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		get_tree().quit()


func _process(delta):
	# Process number
	# TODO find a more elegant way to do this
	var AlphaPerSecond = counters.Counter1.output()
	var AlphaPerSecondTemp = AlphaPerSecond
	var Counter1PerSecond = counters.Counter2.output()
	var Counter1PerSecondTemp = Counter1PerSecond
	var Counter2PerSecond = counters.Counter3.output()
	var Counter2PerSecondTemp = Counter2PerSecond
	var Counter3PerSecond = counters.Counter4.output()
	var Counter3PerSecondTemp = Counter3PerSecond
	
	wallet.alpha.plus(AlphaPerSecondTemp.multiply(delta)) 
	counters.Counter1.add_qty(Counter1PerSecondTemp.multiply(delta))
	counters.Counter2.add_qty(Counter2PerSecondTemp.multiply(delta))
	counters.Counter3.add_qty(Counter3PerSecondTemp.multiply(delta))

	# Process UI changes
	emit_signal("number_changed", [str(wallet.alpha), str(counters.Counter1.output()), float(wallet.alpha.exponent) / 308])
	
	# Let's update the buttons and their progress bar
	for item in counters:
		update_button(item)

	if milestones.sacrifice_alpha_available:
		var phi = calculate_phi()
		if phi > 0:
			emit_signal("update_sacrifice_alpha_btn", phi)

	# Saving some data
	if milestones.game_started:
		stats.time_since_start += delta
		if OS.is_debug_build():
			emit_signal("time_passed", stats.time_since_start)


func buy_counter(item, qty = 1):
	var price = counters[item].price()

	if wallet.alpha.isLargerThanOrEqualTo(price):
		wallet.alpha.minus(price)
		counters[item].add_lvl(qty)

		update_button(item)
		unlock_milestones()


func update_button(item):
	var provider = counters[item].provider
	var qty = counters[item].qty
	var percent = null
	if provider:
		if qty.isLargerThan(0):
			var output = counters[provider].output()
			percent = str(output.divide(qty).multiply(100))
		else:
			percent = "0"
	
	var signal_content = {
			"id": item, 
			"qty": str(counters[item].qty), 
			"price": str(counters[item].price()),
			"multiplier": str(counters[item].multiplier()),
			"percent": percent
	}
	emit_signal("button_update", signal_content)
	emit_signal("update_PB", [item, counters[item].lvl % 10])


func save_game():
	var f = File.new()
	f.open(savefile, File.WRITE)
	f.store_var(save_version)
	f.store_var(milestones)
	var array
	for item in wallet:
		array = [wallet[item].mantissa, wallet[item].exponent]
		f.store_var(array)
	for item in counters:
		array = counters[item].to_array()
		f.store_var(array)
	f.store_var(stats)
	f.close()


func load_game():
	var f = File.new()
	if f.file_exists(savefile):
		f.open(savefile, File.READ)

		# check if savefile is compatible, if not don't load
		var version = f.get_var()
		if version != save_version:
			return

		# recover game data
		milestones = f.get_var()
		var money
		var counter
		for item in wallet:
			money = f.get_var()
			wallet[item].set(money[0], money[1])
		for item in counters:
			counter = f.get_var()
			counters[item].from_array(counter)
		stats = f.get_var()		
		f.close()


func reset_alpha():
	wallet.alpha.set(0)
	emit_signal("number_changed", [str(wallet.alpha), 0, float(wallet.alpha.exponent) / 308])
	emit_signal("update_sacrifice_alpha_btn", 0) # after alpha reset phi to gain is 0

	for item in counters:
		counters[item].reset()
		update_button(item)


func calculate_phi():
	# FUTURE adapt formula as a way to pace the game
	return wallet.alpha.exponent - 14

# TODO refactor completly, this is bad
func unlock_milestones(onload = false, ms = null):
	if milestones.game_started or ms == "game_started":
		emit_signal("milestone_passed", "game_started")
	
	if (onload and milestones.counter1_available) or ms == "counter1_available":
		emit_signal("milestone_passed", "counter1_available")
		if !milestones.counter1_available:
			milestones.counter1_available = stats.time_since_start
		
	if (counters.Counter1.lvl >= 1 and !milestones.counter1_bought) or (onload and milestones.counter1_bought):
		emit_signal("milestone_passed", "counter1_bought")
		if !milestones.counter1_bought:
			milestones.counter1_bought = stats.time_since_start

	if (counters.Counter1.lvl >= 10 and !milestones.counter2_available) or (onload and milestones.counter2_available):
		emit_signal("milestone_passed", "counter2_available")
		if !milestones.counter2_available:
			milestones.counter2_available = stats.time_since_start

	if (counters.Counter2.lvl >= 10 and !milestones.counter3_available) or (onload and milestones.counter3_available):
		emit_signal("milestone_passed", "counter3_available")
		if !milestones.counter3_available:
			milestones.counter3_available = stats.time_since_start

	if (counters.Counter3.lvl >= 10 and !milestones.counter4_available) or (onload and milestones.counter4_available):
		emit_signal("milestone_passed", "counter4_available")
		if !milestones.counter4_available:
			milestones.counter4_available = stats.time_since_start

	if (counters.Counter4.lvl >= 20 and !milestones.sacrifice_alpha_available) or (onload and milestones.sacrifice_alpha_available):
		emit_signal("milestone_passed", "sacrifice_alpha_available")
		if !milestones.sacrifice_alpha_available:
			milestones.sacrifice_alpha_available = stats.time_since_start
	
	if (onload and milestones.phishop_available) or ms == "phishop_available":
		emit_signal("milestone_passed", "phishop_available")
		if !milestones.phishop_available:
			milestones.phishop_available = stats.time_since_start

### SIGNALS ###

func _on_Number_pressed():
	wallet.alpha.plus(1)
	stats.number_clicked += 1
	emit_signal("number_changed", [str(wallet.alpha), 0, float(wallet.alpha.exponent) / 308])
	if wallet.alpha.isLargerThanOrEqualTo(10):
		unlock_milestones(false, "counter1_available")
	if stats.number_clicked > 100:
		achievements.why = stats.time_since_start


func _on_UI_game_started():
	milestones.game_started = true


func _on_PhiSacrifice_pressed():
	var phi = calculate_phi()
	print(phi)
	if phi > 0:
		reset_alpha()
		wallet.phi.plus(phi)
		unlock_milestones(false, "phishop_available")
		emit_signal("phi_changed", str(wallet.phi))


################
# DEBUG TOOLS
################

func _input(event):
	if !OS.is_debug_build():
		return

	if event.is_action_pressed("save"):
		save_game()
	if event.is_action_pressed("load"):
		load_game()
	if event.is_action_pressed("print_report"):
		print_report()
	if event.is_action_pressed("quit_kill_save"):
		var f = File.new()
		if f.file_exists(savefile):
			f.open(savefile, File.WRITE)
			f.store_string('')
			f.close()
		get_tree().quit()
	if event.is_action_pressed("double_number"):
		wallet.alpha.multiply(1.5) 


func print_report():
	print("WALLET CONTENT")
	print(wallet)
	print("\n--------------------\n")
	print("MILESTONES")
	print(milestones)
	print("\n--------------------\n")
	print("STATS")
	print(stats)
