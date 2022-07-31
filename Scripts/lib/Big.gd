class_name Big
extends Reference
# Big number class for use in idle / incremental games and other games that needs very large numbers
# Can format large numbers using a variety of notation methods:
# AA notation like AA, AB, AC etc.
# Metric symbol notation k, m, G, T etc.
# Metric name notation kilo, mega, giga, tera etc.
# Long names like octo-vigin-tillion or millia-nongen-quin-vigin-tillion (based on work by Landon Curt Noll)
# Scientic notation like 13e37 or 42e42
# Long strings like 4200000000 or 13370000000000000000000000000000
# Please note that this class has limited precision and does not fully support negative exponents

var mantissa: float = 0.0
var exponent: int = 1

const postfixes_metric_symbol = {"0":"", "1":"k", "2":"M", "3":"G", "4":"T", "5":"P", "6":"E", "7":"Z", "8":"Y"}
const postfixes_metric_name = {"0":"", "1":"kilo", "2":"mega", "3":"giga", "4":"tera", "5":"peta", "6":"exa", "7":"zetta", "8":"yotta"}
const postfixes_aa = {"0":"", "1":"k", "2":"m", "3":"b", "4":"t", "5":"aa", "6":"ab", "7":"ac", "8":"ad", "9":"ae", "10":"af", "11":"ag", "12":"ah", "13":"ai", "14":"aj", "15":"ak", "16":"al", "17":"am", "18":"an", "19":"ao", "20":"ap", "21":"aq", "22":"ar", "23":"as", "24":"at", "25":"au", "26":"av", "27":"aw", "28":"ax", "29":"ay", "30":"az", "31":"ba", "32":"bb", "33":"bc", "34":"bd", "35":"be", "36":"bf", "37":"bg", "38":"bh", "39":"bi", "40":"bj", "41":"bk", "42":"bl", "43":"bm", "44":"bn", "45":"bo", "46":"bp", "47":"bq", "48":"br", "49":"bs", "50":"bt", "51":"bu", "52":"bv", "53":"bw", "54":"bx", "55":"by", "56":"bz", "57":"ca"}
const alphabet_aa = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

const latin_ones = ["", "un", "duo", "tre", "quattuor", "quin", "sex", "septen", "octo", "novem"]
const latin_tens = ["", "dec", "vigin", "trigin", "quadragin", "quinquagin", "sexagin", "septuagin", "octogin", "nonagin"]
const latin_hundreds = ["", "cen", "duocen", "trecen", "quadringen", "quingen", "sescen", "septingen", "octingen", "nongen"]
const latin_special = ["", "mi", "bi", "tri", "quadri", "quin", "sex", "sept", "oct", "non"]

# short versions
const latin_short_ones = ["", "u", "d", "t", "qa", "qu", "sx", "sp", "o", "n"]
const latin_short_tens = ["", "D", "vigin", "trigin", "quadragin", "quinquagin", "sexagin", "septuagin", "octogin", "nonagin"]
const latin_short_hundreds = ["", "cen", "duocen", "trecen", "quadringen", "quingen", "sescen", "septingen", "octingen", "nongen"]
const latin_short_special = ["", "M", "B", "T", "Qa", "Qt", "Sx", "Sp", "Oc", "No"]

const other = {"dynamic_decimals":true, "small_decimals":2, "thousand_decimals":2, "big_decimals":2, "thousand_separator":"", "decimal_separator":".", "postfix_separator":"", "reading_separator":"", "thousand_name":"k"}

const MAX_MANTISSA = 1209600.0
const MANTISSA_PRECISSION = 0.0000001


func _init(m, e := 0):
	set(m, e)

func set(m, e:= 0):
	if typeof(m) == TYPE_STRING:
		var scientific = m.split("e")
		mantissa = float(scientific[0])
		if scientific.size() > 1:
			exponent = int(scientific[1])
		else:
			exponent = 0
	elif typeof(m) == TYPE_OBJECT:
		if m.is_class("Big"):
			mantissa = m.mantissa
			exponent = m.exponent
	else:
		_sizeCheck(m)
		mantissa = m
		exponent = e
	calculate(self)


func get_class():
	return "Big"


func is_class(c):
	return c == "Big"


func _sizeCheck(m):
	if m > MAX_MANTISSA:
		printerr("BIG ERROR: MANTISSA TOO LARGE, PLEASE USE EXPONENT OR SCIENTIFIC NOTATION")

# Converts to dict mimicking Big
func _typeCheck(n):
	if typeof(n) == TYPE_INT or typeof(n) == TYPE_REAL:
		return {"mantissa":float(n), "exponent":0}
	elif typeof(n) == TYPE_STRING:
		var split = n.split("e")
		return {"mantissa":float(split[0]), "exponent":int(0 if split.size() == 1 else split[1])}
	else:
		return n


func plus(n):
	n = _typeCheck(n)
	_sizeCheck(n.mantissa)
	var exp_diff = n.exponent - exponent
	if exp_diff < 248:
		var scaled_mantissa = n.mantissa * pow(10, exp_diff)
		mantissa += scaled_mantissa
	elif isLessThan(n):
		mantissa = n.mantissa #when difference between values is big, throw away small number
		exponent = n.exponent
	calculate(self)
	return self


func minus(n):
	n = _typeCheck(n)
	_sizeCheck(n.mantissa)
	var exp_diff = n.exponent - exponent #abs?
	if exp_diff < 248:
		var scaled_mantissa = n.mantissa * pow(10, exp_diff)
		mantissa -= scaled_mantissa
	elif isLessThan(n):
		mantissa = -MANTISSA_PRECISSION
		exponent = n.exponent
	calculate(self)
	return self


func multiply(n):
	n = _typeCheck(n)
	_sizeCheck(n.mantissa)
	exponent = exponent + n.exponent
	mantissa = mantissa * n.mantissa
	calculate(self)
	return self


func divide(n):
	n = _typeCheck(n)
	_sizeCheck(n.mantissa)
	if n.mantissa == 0:
		printerr("BIG ERROR: DIVIDE BY ZERO OR LESS THAN " + str(MANTISSA_PRECISSION))
		return self
	exponent = exponent - n.exponent
	mantissa = mantissa / n.mantissa
	calculate(self)
	return self


func power(n: int):
	if n < 0:
		printerr("BIG ERROR: NEGATIVE EXPONENTS NOT SUPPORTED!")
		mantissa = 1.0
		exponent = 0
		return self
	if n == 0:
		mantissa = 1.0
		exponent = 0
		return self

	var y_mantissa = 1
	var y_exponent = 0

	while n > 1:
		calculate(self)
		if n % 2 == 0: #n is even
			exponent = exponent + exponent
			mantissa = mantissa * mantissa
			n = n / 2  # warning-ignore:integer_division
		else:
			y_mantissa = mantissa * y_mantissa
			y_exponent = exponent + y_exponent
			exponent = exponent + exponent
			mantissa = mantissa * mantissa
			n = (n-1) / 2  # warning-ignore:integer_division

	exponent = y_exponent + exponent
	mantissa = y_mantissa * mantissa
	calculate(self)
	return self


func squareRoot():
	if exponent % 2 == 0:
		mantissa = sqrt(mantissa)
		exponent = exponent/2  # warning-ignore:integer_division
	else:
		mantissa = sqrt(mantissa*10)
		exponent = (exponent-1)/2  # warning-ignore:integer_division
	calculate(self)
	return self


func modulo(n):
	n = _typeCheck(n)
	_sizeCheck(n.mantissa)
	var big = {"mantissa":mantissa, "exponent":exponent}
	divide(n)
	roundDown()
	multiply(n)
	minus(big)
	mantissa = abs(mantissa)
	return self


func calculate(big):
	if big.mantissa >= 10.0 or big.mantissa < 1.0:
		var diff = int(floor(log10(big.mantissa)))
		if diff > -10 and diff < 248:
			var div = pow(10, diff)
			if div > MANTISSA_PRECISSION:
				big.mantissa /= div
				big.exponent += diff
	while big.exponent < 0:
		big.mantissa *= 0.1
		big.exponent += 1
	while big.mantissa >= 10.0:
		big.mantissa *= 0.1
		big.exponent += 1
	if big.mantissa == 0:
		big.mantissa = 0.0
		big.exponent = 0
	big.mantissa = stepify(big.mantissa, MANTISSA_PRECISSION)
	pass


func isEqualTo(n):
	n = _typeCheck(n)
	calculate(n)
	return n.exponent == exponent and is_equal_approx(n.mantissa, mantissa)


func isLargerThan(n):
	return !isLessThanOrEqualTo(n)


func isLargerThanOrEqualTo(n):
	return !isLessThan(n)


func isLessThan(n):
	n = _typeCheck(n)
	calculate(n)
	if mantissa == 0 and n.mantissa > MANTISSA_PRECISSION or mantissa < MANTISSA_PRECISSION and n.mantissa == 0:
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


func isLessThanOrEqualTo(n):
	n = _typeCheck(n)
	calculate(n)
	if isLessThan(n):
		return true
	if n.exponent == exponent and is_equal_approx(n.mantissa, mantissa):
		return true
	return false


static func min(m, n):
	if m.isLessThan(n):
		return m
	else:
		return n


static func max(m, n):
	if m.isLargerThan(n):
		return m
	else:
		return n


static func abs(n):
	n.mantissa = abs(n.mantissa)
	return n


func roundDown():
	if exponent == 0:
		mantissa = floor(mantissa)
		return self
	else:
		var precision = 1.0
		for _i in range(min(8, exponent)):
			precision /= 10.0
		if precision < MANTISSA_PRECISSION:
			precision = MANTISSA_PRECISSION
		mantissa = stepify(mantissa, precision)
		return self


func log10(x):
	return log(x) * 0.4342944819032518


func toString():
	var mantissa_decimals = 0
	if str(mantissa).find(".") >= 0:
		mantissa_decimals = str(mantissa).split(".")[1].length()
	if mantissa_decimals > exponent:
		if exponent < 248:
			return str(mantissa * pow(10, exponent))
		else:
			return toScientific()
	else:
		var mantissa_string = str(mantissa).replace(".", "")
		for _i in range(exponent-mantissa_decimals):
			mantissa_string += "0"
		return mantissa_string


func toScientific():
	return str(mantissa) + "e" + str(exponent)


func toShortScientific():
	return str(stepify(mantissa, 0.1)) + "e" + str(exponent)


func toFloat():
	return stepify(float(str(mantissa) + "e" + str(exponent)),0.01)


func toPrefixOld(no_decimals_on_small_values = false):
	var hundreds = 1
	for _i in range(exponent % 3):
		hundreds *= 10
	var number = mantissa * hundreds
	var result = ""
	var split = str(number).split(".")
	if no_decimals_on_small_values and int(exponent / 3) == 0:  # warning-ignore:integer_division
		result = split[0]
	else:
		if split[0].length() == 3:
			result = str("%1.2f" % number).substr(0,3)
		else:
			result = str("%1.2f" % number).substr(0,4)

	return result


func toPrefix(no_decimals_on_small_values = false, use_thousand_symbol=true, force_decimals=true):
	var hundreds = 1
	for _i in range(exponent % 3):
		hundreds *= 10
	var number:float = mantissa * hundreds
	var split = str(number).split(".")
	if force_decimals:
		if split.size() == 1:
			split.append("")
		split[1] += "000"
	var result = split[0]
	if no_decimals_on_small_values and int(exponent / 3) == 0:  # warning-ignore:integer_division
		pass
	elif exponent < 3:
		if split.size() > 1 and other.small_decimals > 0:
			result += other.decimal_separator + split[1].substr(0,min(other.small_decimals, 4 - split[0].length() if other.dynamic_decimals else other.small_decimals))
	elif exponent < 6:
		if use_thousand_symbol:
			if split.size() > 1 and other.thousand_decimals > 0:
				result += other.decimal_separator + split[1].substr(0,min(other.thousand_decimals, 4 - split[0].length() if other.dynamic_decimals else other.small_decimals))
		else:
			if split.size() > 1:
				result += other.thousand_separator + (split[1] + "000").substr(0,3)
			else:
				result += other.thousand_separator + "000"
	else:
		if split.size() > 1 and other.big_decimals > 0:
			result += other.decimal_separator + split[1].substr(0,min(other.big_decimals, 4 - split[0].length() if other.dynamic_decimals else other.small_decimals))

	return result


# warning-ignore:integer_division
func _latinPower(european_system):
	if european_system:
		return int(exponent / 3) / 2  # warning-ignore:integer_division
	return int(exponent / 3) - 1  # warning-ignore:integer_division


# addgin my own because I want short name like s(extiollion), or O(ctillion)
func _latinShortPrefix(european_system):
	var ones = _latinPower(european_system) % 10
	var tens = int(_latinPower(european_system) / 10) % 10
	var hundreds = int(_latinPower(european_system) / 100) % 10
	var millias = int(_latinPower(european_system) / 1000) % 10

	var prefix = ""
	if _latinPower(european_system) < 10:
		prefix = latin_short_special[ones] + other.reading_separator + latin_short_tens[tens] + other.reading_separator + latin_short_hundreds[hundreds]
	else:
		prefix = latin_short_hundreds[hundreds] + other.reading_separator + latin_short_ones[ones] + other.reading_separator + latin_short_tens[tens]

# ??? what's that supposed to be ?? every loop does the same thing.
	for _i in range(millias):
		prefix = "millia" + other.reading_separator + prefix

	return prefix.lstrip(other.reading_separator).rstrip(other.reading_separator)


func _to_string():
	return toShortName(true)

# adding my own because I'm not happy with offered solution
# under 1 000 displays displays the thousand symbol
# Above 999 999 displays short latin (B, T, Qa, Qt, Sx, Sp, Oc, No, Dc)
# above 1e36 displays scientific
func toShortName(no_decimals_on_small_values = false, european_system = false):
	if exponent < 6:
		if exponent > 2: 
			return toPrefix(no_decimals_on_small_values) + other.postfix_separator + other.thousand_name
		else:
			return toPrefix(no_decimals_on_small_values)
	elif exponent > 36:
		return	toShortScientific()

	var postfix = _latinShortPrefix(european_system)
	
	return toPrefix(no_decimals_on_small_values) + other.postfix_separator + postfix


