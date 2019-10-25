Import Closure
Import Implicit-Coerce
Import IO

List-to-Tuple(list) {
	;; Removes trailing 'nil' if present to convert a list to a tuple
	List-to-Tuple = list

	(x xs) = list
	List-to-Tuple = Nil?(xs) : x
					(x Recur(xs))
}

As-List(set...) {
	As-List = Nil?(set...) : set... [set...]
	(x xs) = set...
	As-List = (x Recur(xs))
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
	;; Returns the difference between x and the largest integer less or equal to it
	Fraction = x - Floor(x)
}

Package Reactive {
	Couple(signals) {
		;; Resamples all of 'signals' to the dominant clock in the set.
		Couple = Reactive:Resample(signals signals)
	}
}

Package String {
	Concat(strs) {
		Concat = Coerce("" strs)
		(s ss) = strs
		Concat = Nil?(ss) : Coerce("" s)
				 String:Append(Coerce("" s) Concat(ss))
	}
}

Infix+ = :Add
Infix- = :Sub
Infix* = :Mul
Infix/ = :Div
Infix!= = :Not-Equal
Infix== = :Equal
Infix> = :Greater
Infix>= = :Greater-Equal
Infix< = :Less
Infix<= = :Less-Equal
Infix& = :And
Infix| = :Or
Infix<- = :LeftArrow
Infix==t = :Equal-Type