class_name Counter
extends Reference

const Big = preload("res://Scripts/lib/Big.gd")

var lvl
var qty
var start_price
var price_multiplier
var currency
var provider


func _init(start = 0, multiplier = 0, prov = null, cur = "alpha"):
	start_price = Big.new(start)
	price_multiplier = Big.new(multiplier)
	currency = cur
	lvl = 0
	qty = Big.new(0)
	provider = prov
	
func reset():
	lvl = 0
	qty = Big.new(0)
	
func rank():
	return int(lvl/10)

func price() -> Big:
	var price_divider = 1 # FUTURE this will be improved by phi items
	var temp_price = Big.new(start_price)
	var temp_mult = Big.new(price_multiplier)
	return temp_price.multiply(temp_mult.power(rank())).divide(price_divider)

func output() -> Big:
	var temp_qty = Big.new(qty)
	return temp_qty.multiply(multiplier())
	
func multiplier():
	var efficiency = 1.0 # FUTURE this will be improved to 1.5 and more with phi items
	var counter_improvement = 1 # FUTURE this will be improved by future mechanic and will be countrer specific
	return (pow(2, rank()) * efficiency) * counter_improvement

func add_qty(amount):
	qty.plus(amount)

func add_lvl(amount):
	qty.plus(amount)
	lvl += amount


# Switch to
func to_array():
	var array = [
			lvl,
			qty.mantissa,
			qty.exponent,
			start_price.mantissa,
			start_price.exponent,
			price_multiplier.mantissa,
			price_multiplier.exponent,
			currency,
			provider
	]
	return array


func from_array(array):
	lvl = array[0]
	qty.mantissa = array[1]
	qty.exponent = array[2]
	start_price.mantissa = array[3]
	start_price.exponent = array[4]
	price_multiplier.mantissa = array[5]
	price_multiplier.exponent = array[6]
	currency = array[7]
	provider = array[8]

