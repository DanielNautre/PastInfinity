extends Control

signal game_started

var numberFormat = "%s   "

func _enter_tree():
#	let's hide a bunch of UI to reveal as player progresses
	$Intro.show()
	$MainView.hide()
	$MainView/BottomBar.hide()
	$MainView/Alpha/PhiShop.hide()
	$MainView/Alpha/AlphaShop/Counter1.hide()
	$MainView/Alpha/AlphaShop/Counter2.hide()
	$MainView/Alpha/AlphaShop/Counter3.hide()
	$MainView/Alpha/AlphaShop/Counter4.hide()
	$MainView/Alpha/AlphaShop/PhiSacrifice.hide()
	$MainView/Alpha/AlphaPhiButtons.hide()
	$MainView/Alpha/AlphaPB/NumberDisplay/NumberPerSecond.hide()
	# 1st Counter elements
	$MainView/Alpha/AlphaShop/Counter1/AmountLbl.hide()
	$MainView/Alpha/AlphaShop/Counter1/PerCentPerSecond.hide()
	$MainView/Alpha/AlphaShop/Counter1/PriceLbl.hide()
	$MainView/Alpha/AlphaShop/Counter1/Multiplier.hide()


func _ready():
	pass

func _on_Start_pressed():
	emit_signal("game_started")
	$Intro.hide()
	$MainView.show()

func _on_AlphaShopBtn_pressed():
	$MainView/Alpha/PhiShop.hide()
	$MainView/Alpha/AlphaShop.show()

func _on_PhiShopBtn_pressed():
	$MainView/Alpha/PhiShop.show()
	$MainView/Alpha/AlphaShop.hide()

func _on_Game_number_changed(number):
	find_node("NumberDisplay").text = numberFormat % number[0]
	$MainView/Alpha/AlphaPB/NumberDisplay/NumberPerSecond.text = "%s/s" % number[1]
	if number[2] > 0.1: # only display progress once passed 10%
		find_node("AlphaPB").value = number[2]

#TODO move to button update
func _on_Game_update_PB(values):
		var node = find_node(values[0])
		node.value = values[1]

func _on_Game_button_update(data):
	var node = find_node(data["id"])
	var amount = node.get_node("AmountLbl")
	var multiplier = node.get_node("Multiplier")
	var price = node.get_node("PriceLbl")
	var percent = node.get_node("PerCentPerSecond")
	amount.text = "%s" % data["qty"]
	price.text = "%s α" % data["price"]
	multiplier.text = "x%s" % data["multiplier"]
	if data["percent"]:
		percent.text = "(+%s%%/s)" % data["percent"]
	else:
		percent.text = ""

func _on_Game_milestone_passed(milestone):
	if milestone == "game_started":
		$Intro.hide()
		$MainView.show()
		return
	if milestone == "counter_available":
		$MainView/Alpha/AlphaShop/Counter1.show()
		return
	if milestone == "counter_bought":
		numberFormat = "%s α "
		$MainView/Alpha/AlphaShop/Counter1/PriceLbl.show()
		$MainView/Alpha/AlphaShop/Counter1/AmountLbl.show()
		return
	if milestone == "ten_counter1":
		$MainView/Alpha/AlphaShop/Counter2.show()
		$MainView/Alpha/AlphaPB/NumberDisplay/NumberPerSecond.show()
		$MainView/Alpha/AlphaShop/Counter1/Multiplier.show()
		$MainView/Alpha/AlphaShop/Counter1/PerCentPerSecond.show()
		return
	if milestone == "ten_counter2":
		$MainView/Alpha/AlphaShop/Counter3.show()
		return
	if milestone == "ten_counter3":
		$MainView/Alpha/AlphaShop/Counter4.show()
		return
	if milestone == "sacrifice_alpha_available":
		$MainView/Alpha/AlphaShop/PhiSacrifice.show()
		return
	if milestone == "phishop_available":
		$MainView/Alpha/AlphaPhiButtons.show()
		return


func _on_Game_time_passed(time):
	$MainView/TimeElapsed.text = "%.1fs" % time


func _on_Game_update_sacrifice_alpha_btn(phi):
	$MainView/Alpha/AlphaShop/PhiSacrifice.text = "Sacrifice for %d φ" % phi
