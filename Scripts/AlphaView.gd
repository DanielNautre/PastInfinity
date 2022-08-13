extends Control

export (Resource) var alpha


var bought_item_theme = preload("res://Ressources/Themes/ItemBtnBought.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	alpha.connect("alpha_changed", self, "_on_alpha_changed")


func _on_alpha_changed(data):
	$AlphaPB/NumberDisplay.text = data


func _on_counter_1_available():
	$AlphaShop/Counter1.show()


func _on_counter_2_available():
	$AlphaShop/Counter2.show()


func _on_counter_3_available():
	$AlphaShop/Counter3.show()


func _on_counter_4_available():
	$AlphaShop/Counter4.show()


func _on_counter_5_available():
	$AlphaShop/Counter5.show()
	$PhiShop/PhiPerks/FlowContainer/AddFifthCounter.disabled = true
	$PhiShop/PhiPerks/FlowContainer/AddFifthCounter.set_theme(bought_item_theme)


func _on_counter_6_available():
	$AlphaShop/Counter6.show()
	$PhiShop/PhiPerks/FlowContainer/AddSixthCounter.disabled = true
	$PhiShop/PhiPerks/FlowContainer/AddSixthCounter.set_theme(bought_item_theme)


func _on_counter_1_bought():
	$AlphaShop/Counter1/AmountLbl.show()
	$AlphaShop/Counter1/PerCentPerSecond.show()
	$AlphaShop/Counter1/PriceLbl.show()
	$AlphaShop/Counter1/Multiplier.show()
	$AlphaPB/NumberDisplay/NumberPerSecond.show()


func _on_Milestones_improved_counter_6():
	$PhiShop/PhiPerks/FlowContainer/BetterSixthCounter.disabled = true
	$PhiShop/PhiPerks/FlowContainer/BetterSixthCounter.set_theme(bought_item_theme)


func update_counter_buttons(data):
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

func update_PB(values):
	var node = find_node(values[0])
	node.value = values[1]


func _on_update_speed(n):
	$AlphaPB/NumberDisplay/NumberPerSecond.text  = "%s/s" % n[0]
	if n[1] > 0.1: # only display progress once passed 10%
		find_node("AlphaPB").value = n[1]


func _on_sacrifice_alpha_available():
	$AlphaShop/PhiSacrifice.show()


func _on_phishop_available():
	$AlphaPhiButtons.show()


func _on_PhiPerks_pressed():
	$PhiShop/PhiPerks.show()
	$PhiShop/PhiUnlocks.hide()
	$PhiShop/PhiShopTabs/PhiUnlocks.disabled = false
	$PhiShop/PhiShopTabs/PhiPerks.disabled = true


func _on_PhiUnlocks_pressed():
	$PhiShop/PhiPerks.hide()
	$PhiShop/PhiUnlocks.show()
	$PhiShop/PhiShopTabs/PhiUnlocks.disabled = true
	$PhiShop/PhiShopTabs/PhiPerks.disabled = false


func _on_update_phi_sacrifice(value):
	if $AlphaShop/PhiSacrifice.is_visible():
		$AlphaShop/PhiSacrifice.text = "Sacrifice for %d φ" % value


func _on_AlphaShopBtn_pressed():
	$AlphaShop.show()
	$PhiShop.hide()


func _on_PhiShopBtn_pressed():
	$AlphaShop.hide()
	$PhiShop.show()
	_on_PhiPerks_pressed() # Make sure we have a default view TODO remember where the user was last. Not a priority


func _on_speed_improvement(data):
	$PhiShop/PhiPerks/FlowContainer/ImproveSpeed/Price.text = "%d φ" % data[1]
