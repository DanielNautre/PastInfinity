extends Node

signal load_intro
signal time_passed
signal update_speed
signal update_phi_sacrifice


onready var Player = $Player
onready var Counters = $Player/Counters
onready var Milestones = $Player/Milestones
onready var PhiItems = $Player/PhiItems

var savefile := "user://PastInfinity.save"
var progressfile := "user://PastInfinityProgress.txt"


# Called when the node enters the scene tree for the first time.
func _ready():
	if !load_game():
		emit_signal("load_intro")
	else:
		call_deferred("refresh_UI")
		PhiItems.unlock_items() # makes sure we have phi unlocks done


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		get_tree().quit() # default behavior


func refresh_UI():
	Milestones.unlock()
	Player.phi.refresh_UI()
	Player.alpha.refresh_UI()


func _process(delta):
	if Milestones.is_unlocked("game_started"):
		Player.stats.time_passed += delta
		if OS.is_debug_build():
			emit_signal("time_passed", Player.stats.time_passed)

	var alpha_second = Counters.Counter1.output()
	
	if OS.has_feature("editor"):
		delta = delta * 5
		pass
	
	Player.alpha.add(alpha_second.multiply(delta))
	Counters.Counter1.add_qty(Counters.Counter2.output().multiply(delta))
	Counters.Counter2.add_qty(Counters.Counter3.output().multiply(delta))
	Counters.Counter3.add_qty(Counters.Counter4.output().multiply(delta))
	Counters.Counter4.add_qty(Counters.Counter5.output().multiply(delta))
	Counters.Counter5.add_qty(Counters.Counter6.output().multiply(delta))
	
	emit_signal("update_phi_sacrifice", Player.phi.alpha_to_phi(Player.alpha))
	emit_signal("update_speed", [alpha_second, float(Player.alpha.exponent) / 308])
	Counters.update_button()
	

func start_game():
	Milestones.unlock("game_started")


func _on_Number_pressed():
	Player.alpha.add(1)
	Player.stats.number_clicked += 1
	if Player.stats.number_clicked > 9 and !Milestones.is_unlocked("counter_1_available"):
		Milestones.unlock("counter_1_available")


func load_game():
	var f = File.new()
	if !f.file_exists(savefile):
		return  false
	f.open(savefile, File.READ)
	while f.get_position() < f.get_len():
		var data = f.get_var()
		find_node(data.Node).load(data)
	f.close()
	
	return true


func save_game():
	var f = File.new()
	f.open(savefile, File.WRITE)
	var nodes = get_tree().get_nodes_in_group("Persist")
	for node in nodes:
		if !node.has_method("save"):
			print(node, " lacks save method")
			continue
		var data = node.call("save")
		f.store_var(data)
	f.close()
	


func _input(event):
	if !OS.has_feature("editor"):
		return

	if event.is_action_pressed("save"): #F5
		save_game()
	if event.is_action_pressed("load"): #F6
		load_game()
	if event.is_action_pressed("print_report"): #F12
		print_report()
	if event.is_action_pressed("quit_kill_save"): #F8
		var f = File.new()
		if f.file_exists(savefile):
			f.open(savefile, File.WRITE)
			f.store_string('')
			f.close()
		get_tree().quit()
	if event.is_action_pressed("double_number"): #F1
		Player.alpha.add(Player.alpha)


func _on_PhiSacrifice_pressed():
	var phi = Player.phi.alpha_to_phi(Player.alpha)
	if phi <= 0:
		return
		
	Player.alpha.reset()
	Counters.reset()
	Player.phi.add(phi)
	Player.stats.phi_sacrifices_overall += 1
	Player.stats.phi_sacrifices_this_round += 1
	Milestones.unlock("phishop_available")


func print_report():
	print("\n----------------------------------------------------------\n")
	print("Progress Report after ", Player.stats.time_passed, " seconds\n")
	print("Alpha: ", Player.alpha)
	print("Phi: ", Player.phi)
	print("Milestones: ", Milestones.list)
	print("Stats: ", Player.stats)
	print("\n----------------------------------------------------------\n")



func _on_SaveProgressReport_timeout():
	if !OS.has_feature("debug"): # if we're not on a debug build, cancel the timer and leave
		$SaveProgressReport.stop()
		return
	if Milestones.is_unlocked("game_started"):
		print_report()
