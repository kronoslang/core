Import Algorithm
Import Closure

Package Test {
	Simple-Expand() {
		invariant = Algorithm:Expand(#10 (+ #1) #1)
		variant = Algorithm:Expand(#10 (+ 1) 1)
		Simple-Expand = ( "\n"
			invariant "\n"
			variant "\n"
			)
	}

	Nested-Expand() {
		inner = x => Algorithm:Expand(#10 (+ x) x)
		invariant = Algorithm:Map(inner inner(#1))		
		variant = Algorithm:Map(inner inner(1))
		Nested-Expand = ( "\n"
			invariant "\n"
			variant "\n"
			)
	}

	Simple-Accumulate() {
		Simple-Accumulate = Algorithm:Accumulate((+) Algorithm:Expand(#50 (+ 1) 1))
	}

	Map-And-Zip() {
		samples = #10
		phases = Algorithm:Map(
			( * (#2 * #3.1415 / samples))
			Algorithm:Expand(samples (+ 1) 0))

		cos-series = Algorithm:Map(Math:Cos phases)
		sin-series = Algorithm:Map(Math:Sin phases)

		Map-And-Zip = Algorithm:Zip-With(
			(a b) => (a b Math:Sqrt(a * a + b * b))
			cos-series
			sin-series)
	}

	Big-Reduce() {
		long-series = Algorithm:Expand(#100000 (+ 1q) 1q)
		Big-Reduce = Algorithm:Reduce((+) long-series)
	}

	Reverse-Reduce() {
		series = Algorithm:Expand(#50 (/ 2) 1000000000)
		Reverse-Reduce = Algorithm:Reduce((a b) => (b a) series)
	}

	Simple-Filter() {
		strings = ["tad" "longer string" "very long string" "bit" "more stuff" "less"]
		Simple-Filter = [
			"long:  " Algorithm:Filter({String:Length(arg) > #4} strings) "\n"
			"short: " Algorithm:Filter({String:Length(arg) <= #4} strings )
			]
	}
}