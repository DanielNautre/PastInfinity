extends Big
class_name Phi

signal phi_changed
signal phi_spent(n)
signal phi_item_available


func _init(m := 0, e := 0).(m, e):
	pass


func _to_string():
	return ._to_string() + " φ"


func add(n):
	var ret = plus(n)
	mantissa = ret.mantissa
	exponent = ret.exponent
	refresh_UI()


func spend(n):
	if gte(n):
		emit_signal("phi_spent", n)
		var ret = minus(n)
		self.mantissa = ret.mantissa
		self.exponent = ret.exponent
		refresh_UI()


func reset():
	exponent = 0
	mantissa = 0
	refresh_UI()


func alpha_to_phi(alpha):
	return max(alpha.exponent - 14, 0)


func refresh_UI():
	print("PHI UI Refresh", str(self))
	emit_signal("phi_changed", str(self))


func serialize():
	var data = {
		"mantissa": mantissa,
		"exponent": exponent,
	}
	return data


func restore(data):
	mantissa = data.mantissa
	exponent = data.exponent
