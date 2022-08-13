class_name Counter
extends Resource

const Big = preload("res://Scripts/lib/Big.gd")

export (int) var lvl
export (Resource) var qty
export (Resource) var start_price
export (Resource) var price_multiplier
export (String) var provider


var efficiency = 1.0 # FUTURE this will be improved to 1.5 and more with phi items
var counter_improvement = 1 # FUTURE this will be improved by future mechanic and will be countrer specific
var price_divider = 1 # FUTURE this will be improved by phi items

var base_tickspeed = 1
var tick_speed = 1


func _init(start = 0, multiplier = 0, prov = null):
	start_price = Big.new(start)
	price_multiplier = Big.new(multiplier)
	lvl = 0
	qty = Big.new(0)
	provider = prov


func set(start = 0, multiplier = 0, prov = null):
	start_price = Big.new(start)
	price_multiplier = Big.new(multiplier)
	provider = prov


func reset():
	lvl = 0
	qty = Big.new(0)


func rank():
	return int(lvl/10)


func price() -> Big:
	return start_price.multiply(price_multiplier.pow(rank())).divide(price_divider)


func output() -> Big:
	return qty.multiply(multiplier()).multiply(tick_speed)


func multiplier():
	return (pow(2, rank()) * efficiency) * counter_improvement


func add_qty(amount):
	qty = qty.plus(amount)


func add_lvl(amount):
	qty = qty.plus(amount)
	lvl += amount


func gte(n):
	return true if lvl >= n else false


# Switch to
func serialize():
	var data = {
			"lvl": lvl,
			"qty": qty.serialize(),
			"start_price": start_price.serialize(),
			"price_multiplier": price_multiplier.serialize(),
			"provider": provider,
			"tick_speed": tick_speed,
	}
	return data


func restore(data):
	lvl = data.lvl
	qty.restore(data.qty)
	start_price.restore(data.start_price)
	price_multiplier.restore(data.price_multiplier)
	provider = data.provider
	tick_speed = data.tick_speed

