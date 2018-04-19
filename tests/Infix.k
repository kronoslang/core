Package Test {
	Custom-Infix() {
		Infix-- = (a b) => (x => Eval(b Eval(a x)))
		composition = (+ 20) -- (* 3) -- Math:Sqrt
		Custom-Infix = composition(10)
	}
}