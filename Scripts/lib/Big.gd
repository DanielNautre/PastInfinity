extends Resource
class_name Big

# This class aims to store huge numbers for use in idle and incremental games
# It is a rewrite of the GodotBigNumberClass by ChronoDK
# https://github.com/ChronoDK/GodotBigNumberClass
#
# Not all function were re-implemented as I tailored it to by needs
# Extends Resource so that it can be serialized by Godot
# This does not handle negative numbers
# Calculation on numbers with large order of magntitude difference is fudged
# Calculation now return the result without changing the current instance
# -> This is more consistant with how operations work on other number types
# -> You can still chain them

export (float) var mantissa: float = 0.0
export (int) var exponent: int = 0

const MAX_MANTISSA := 1209600.0
const MANTISSA_PRECISION := 0.0000001

const short_name = ["k", "M", "B", "T", "Qa", "Qt", "Sx", "Sp", "Oc", "No", "Dc"]

var Big = load("res://Scripts/lib/Big.gd")


# this lacks error handling if not receiving expected values
func _init(m, e := 0):
	match typeof(m):
		TYPE_STRING:
			var scientific = m.split("e")
			mantissa = float(scientific[0])
			if scientific.size() > 1:
				exponent = int(scientific[1])
			else:
				exponent = 0
		TYPE_OBJECT:
			if m.is_class("Big"):
				mantissa = m.mantissa
				exponent = m.exponent
		_:
			_size_check(m)
			mantissa = m
			exponent = e
	normalize()


func _to_string():
	if exponent > 35: # more than 999 Dc
		return str(stepify(mantissa, 0.1)) + "e" + str(exponent)
	elif exponent < 3: # less than 1k TODO figure out how to change _to_prefix to allow up to 10k
		return _to_prefix()

	# from 10k to 999 Dc
	var index = (int(exponent / 3) - 1 ) % 11  # warning-ignore:integer_division
	return _to_prefix() + short_name[index]


# TODO optimize massively
func _to_prefix():
	var hundreds = 1
	for _i in range(exponent % 3):
		hundreds *= 10
	var number:float = mantissa * hundreds
	var split = str(number).split(".")

	if split.size() == 1:
		split.append("")
	split[1] += "000"
	
	var result = split[0]
	if int(exponent / 3) == 0:  # warning-ignore:integer_division
		pass
	elif exponent < 6:
		if split.size() > 1:
			result += "." + split[1].substr(0, min(2, 4 - split[0].length()))
		else:
			result += "." + "000"
	else:
		if split.size() > 1:
			result += "." + split[1].substr(0, min(2, 4 - split[0].length()))

	return result


func get_class():
	return "Big"


func is_class(c):
	return c == "Big"


# MATHS
# All maths is done between type Big to make it easier
# so first step is always to convert to a Big

func eq(n) -> bool:
	n = Big.new(n)
	return n.exponent == exponent and is_equal_approx(n.mantissa, mantissa)


func lt(n) -> bool:
	n = Big.new(n)
	if mantissa == 0 and n.mantissa > MANTISSA_PRECISION:
		return true
	if exponent < n.exponent:
		return true
	elif exponent == n.exponent:
		if mantissa < n.mantissa:
			return true
		else:
			return false
	else:
		return false


func lte(n) -> bool:
	n = Big.new(n)
	if lt(n):
		return true
	if n.exponent == exponent and is_equal_approx(n.mantissa, mantissa):
		return true
	return false


func ne(n) -> bool:
	return !eq(n)


func gt(n) -> bool:
	return !lte(n)


func gte(n) -> bool:
	return !lt(n)


func plus(n):
	n = Big.new(n)
	var ret = Big.new(0)
	var exp_diff = n.exponent - exponent
	if exp_diff < 248: # small diff, so we calcalute precisely and we normalize
		var scaled_mantissa = n.mantissa * pow(10, exp_diff)
		ret.mantissa = mantissa + scaled_mantissa
		ret.exponent = exponent
	elif lt(n): # n much bigger than self, so we ignore self and use n
		ret.mantissa = n.mantissa 
		ret.exponent = n.exponent
	return ret.normalize()


func minus(n):
	n = Big.new(n)
	var ret = Big.new(0)
	var exp_diff = n.exponent - exponent #abs?
	if exp_diff < 248: # small diff, so we calcalute precisely and we normalize
		var scaled_mantissa = n.mantissa * pow(10, exp_diff)
		ret.mantissa = mantissa - scaled_mantissa
		ret.exponent = exponent
	elif lt(n):  # n much bigger than self, so we ignore self and use n
		ret.mantissa = -MANTISSA_PRECISION # not sure why we would do that ?
		ret.exponent = n.exponent
	return ret.normalize()


func multiply(n):
	n = Big.new(n)
	var ret = Big.new(0)
	ret.exponent = exponent + n.exponent
	ret.mantissa = mantissa * n.mantissa
	return ret.normalize()


func divide(n):
	n = Big.new(n)
	var ret = Big.new(0)
	if n.mantissa == 0:
		printerr("Math error: division by 0")
		return self
	ret.exponent = exponent - n.exponent
	ret.mantissa = mantissa / n.mantissa
	return ret.normalize()


func sqrt():
	var ret = Big.new(0)
	if exponent % 2 == 0:
		ret.mantissa = sqrt(mantissa)
		ret.exponent = exponent / 2  # warning-ignore:integer_division
	else:
		ret.mantissa = sqrt(mantissa * 10)
		ret.exponent = (exponent - 1) / 2  # warning-ignore:integer_division
	return ret.normalize()


func pow(n: int):
	var ret = Big.new(self)
	if n < 0:
		printerr("Invalid value: pow only support positive exponent")
	if n == 0:
		ret.mantissa = 1.0
		ret.exponent = 0
		return ret

	var y_mantissa = 1
	var y_exponent = 0

	while n > 1:
		ret.normalize()
		if n % 2 == 0: # n is even
			ret.exponent = ret.exponent + ret.exponent
			ret.mantissa = ret.mantissa * ret.mantissa
			n = n / 2  # warning-ignore:integer_division
		else:
			y_mantissa = ret.mantissa * y_mantissa
			y_exponent = ret.exponent + y_exponent
			ret.exponent = ret.exponent + ret.exponent
			ret.mantissa = ret.mantissa * ret.mantissa
			n = (n - 1) / 2  # warning-ignore:integer_division

	ret.exponent = y_exponent + ret.exponent
	ret.mantissa = y_mantissa * ret.mantissa
	
	return ret.normalize()


func modulo(n):
	n = Big.new(n)
	var ret = divide(n).round_down().multiply(n).minus(self)  # ie (floor(self / n) * n) - self
	ret.mantissa = abs(ret.mantissa)
	return ret.normalize()


static func abs(n):
	n.mantissa = abs(n.mantissa)
	return n


func round_down():
	var ret = Big.new(0)
	ret.exponent = exponent
	if exponent == 0:
		ret.mantissa = floor(mantissa)
		return ret.normalize()
	else:
		var precision = 1.0
		for _i in range(min(8, exponent)):
			precision /= 10.0
		if precision < MANTISSA_PRECISION:
			precision = MANTISSA_PRECISION
		ret.mantissa = stepify(mantissa, precision)
		return ret.normalize()


#### HELPER FUNCTIONS

func _size_check(m):
	if m > MAX_MANTISSA:
		printerr("mantissa exceeds max value, %d instead of %d" % [m, MAX_MANTISSA])


# Approximate log10, accuracy sufficient for this class
static func log10(n):
	return log(n) * 0.4342944819032518


static func min(m, n):
	if m.lt(n):
		return m
	else:
		return n


static func max(m, n):
	if m.gt(n):
		return m
	else:
		return n


# Makes sure mantissa is between 0 and 9 (included) and exponent is not negative
func normalize():
	if mantissa >= 10.0 or mantissa < 1.0:
		var diff = int(floor(log10(mantissa)))
		if diff > -10 and diff < 248:
			var div = pow(10, diff)
			if div > MANTISSA_PRECISION:
				mantissa /= div
				exponent += diff
	while exponent < 0:
		mantissa *= 0.1
		exponent += 1
	while mantissa >= 10.0:
		mantissa *= 0.1
		exponent += 1
	if mantissa == 0:
		mantissa = 0.0
		exponent = 0
	mantissa = stepify(mantissa, MANTISSA_PRECISION)
	return self


func serialize():
	var data = {
		"mantissa": mantissa,
		"exponent": exponent,
	}
	return data


func restore(data):
	mantissa = data.mantissa
	exponent = data.exponent
