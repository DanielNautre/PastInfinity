extends Control


export (Resource) var phi

var available_item_theme = preload("res://Ressources/Themes/ItemBtnAvailable.tres")
var unavailable_item_theme = preload("res://Ressources/Themes/ItemBtnUnavailable.tres")
var bought_item_theme = preload("res://Ressources/Themes/ItemBtnBought.tres")

func _ready():
	phi.connect("phi_changed", self, "_on_phi_changed")
	phi.connect("phi_item_available", self, "_on_phi_item_available")
	

func _on_phi_changed(data):
	$PhiPerks/Phi.text = data


func _on_PhiItems_show_phi_spent(data):
	$PhiUnlocks/VBoxContainer/SpentPhi/NameLbl.text = "%s φ spent in total" % data


func _on_PhiItems_unlock_phi_item(data):
	var node = find_node(data) as Button
	node.set_theme(available_item_theme)
	node.disabled = false
	

func _on_PhiItems_lock_phi_item(data):
	var node = find_node(data) as Button
	node.set_theme(unavailable_item_theme)
	node.disabled = true


func _on_Milestones_first_phi_unlock():
	$PhiUnlocks/VBoxContainer/Item1.set_theme(bought_item_theme)


func _on_Milestones_second_phi_unlock():
	$PhiUnlocks/VBoxContainer/Item2.set_theme(bought_item_theme)


func _on_Milestones_fourth_phi_unlock():
	$PhiUnlocks/VBoxContainer/Item4.set_theme(bought_item_theme)
