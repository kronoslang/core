Import Closure
Import Implicit-Coerce
Import IO

List-to-Tuple(list) {
	;; Removes trailing 'nil' to convert a list to a tuple
	(x xs) = list
	List-to-Tuple = Nil?(xs) : x
					(x Recur(xs))
}

Tuple-to-List(tuple) {
	;; Adds trailing 'nil' to convert a tuple to a list
	Tuple-to-List = [tuple]
	(x xs) = tuple
	Tuple-to-List = (x Recur(xs))
}

Apply(func list) {
	;; Applies 'list' as an argument tuple to 'func'
	Apply = func(List-to-Tuple(list))
}

Fraction(x) {
	Fraction = x - Floor(x)
}

Package Reactive {
	Couple(signals) {
		Couple = Reactive:Resample(signals signals)
	}
}

Package String {
	Concat(strs) {
		Concat = strs
		(s ss) = strs
		Concat = Nil?(ss) : s 
				 String:Append(s Concat(ss))
	}
}

