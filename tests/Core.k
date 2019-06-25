Import Algorithm

foo = "bar"
baz = Math:Sqrt

bazMap() {
	Algorithm:Map(baz 1 2 3 4 5)
}

Expect-Error(exception) {
	String:Concat("As planned, error: " exception)
}

Package Test {
	Binding() {
		[foo
		 With-Binding(":foo" "baz" { foo })
		 foo]
	}

	Function-Binding() {
		[bazMap()
		 With-Binding(":baz" (* 3) bazMap)
		 bazMap()]
	}

	Cycle-Error() {
		Handle(Eval({ x = x x} nil) Expect-Error)
	}

	Infix-Override() {
		Infix+ = (a b) => Sub(a b)
		Infix- = (a b) => Add(a b)
		[1 + 10 100 - 1000]
	}

	Type-Failure() {
		FMA(a b c) {
			a + b * c
		}
		Handle(FMA(1 2 "foo") Expect-Error)
	}

	Slice-Subarray() {
		Use Algorithm
		xs = Expand(#20 (+ 1) 1)
		Map(o => Slice(xs o #5) Expand(#60 (+ 1) -20))
	}
}