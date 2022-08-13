extends Control


func _ready():
	pass

func _enter_tree():
	# make sure we have the right nodes displayed at init
	$MainView/Alpha/AlphaShop.show()
	
	# Hide a bunch of stuff for later reveal
	$MainView/BottomBar.hide()
	$MainView/Alpha/AlphaPB/NumberDisplay/NumberPerSecond.hide()
	
	# hide the counters button
	$MainView/Alpha/AlphaShop/Counter1.hide()
	$MainView/Alpha/AlphaShop/Counter2.hide()
	$MainView/Alpha/AlphaShop/Counter3.hide()
	$MainView/Alpha/AlphaShop/Counter4.hide()
	$MainView/Alpha/AlphaShop/Counter5.hide()
	$MainView/Alpha/AlphaShop/Counter6.hide()
	
	# 1st Counter elements
	$MainView/Alpha/AlphaShop/Counter1/AmountLbl.hide()
	$MainView/Alpha/AlphaShop/Counter1/PerCentPerSecond.hide()
	$MainView/Alpha/AlphaShop/Counter1/PriceLbl.hide()
	$MainView/Alpha/AlphaShop/Counter1/Multiplier.hide()
	
	# hide the phi & sacrifice
	$MainView/Alpha/AlphaShop/PhiSacrifice.hide()
	$MainView/Alpha/AlphaPhiButtons.hide()
	$MainView/Alpha/PhiShop.hide()
	$MainView/Alpha/PhiShop/PhiUnlocks.hide()


func _load_intro():
	$MainView.hide()
	$Intro.show()


func _start_game_pressed():
	$Intro.hide()
	# Display the main view and start the game
	$MainView.show()
	$GameController.start_game()
