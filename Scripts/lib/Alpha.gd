extends Big
class_name Alpha

signal alpha_changed

var counter_1_bought = false


func _init(m := 0, e := 0).(m, e):
	pass


func _to_string():
	if counter_1_bought:
		return ._to_string() + " α"
	else:
		return ._to_string() + "  "


func add(n):
	var ret = plus(n)
	mantissa = ret.mantissa
	exponent = ret.exponent
	emit_signal("alpha_changed", str(self))


func spend(n):
	if gte(n):
		var ret = minus(n)
		self.mantissa = ret.mantissa
		self.exponent = ret.exponent
		emit_signal("alpha_changed", str(self))


func reset():
	exponent = 0
	mantissa = 0
	emit_signal("alpha_changed", str(self))


func refresh_UI():
	emit_signal("alpha_changed", str(self))


func serialize():
	var data = {
		"mantissa": mantissa,
		"exponent": exponent,
		"counter_1_bought": counter_1_bought,
	}
	return data


func restore(data):
	mantissa = data.mantissa
	exponent = data.exponent
	counter_1_bought = data.counter_1_bought
