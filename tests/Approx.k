Import Approx 

Package Test {
	Cosine() {
		indices = Algorithm:Expand(#10 (+ 0.05) 0)
		orders = Algorithm:Expand(#5 (+ #1) #2)
		precise = 'Math:Cos(_ * 2 * 3.14159265358979)
		Cosine = 
			Algorithm:Map(
				order => ("\nOrder" order "error:" 
					Algorithm:Map(x => (precise(x) - Approx:Cosine-Shape(x order)) 
								  indices))
				orders)

	}

	Faster() {
		Use Approx:Faster
		fns = [Log2 Log Pow2 x => Pow(x x) Exp Sigmoid Sinh Cosh]
		vals = Algorithm:Expand(#10 (+ 2) -10)
		Algorithm:Map(fn => Algorithm:Map(fn vals) fns)
	}

	Fast() {
		Use Approx:Fast
		fns = [Log2 Log Pow2 x => Pow(x x) Exp Sigmoid Sinh Cosh Tanh]
		vals = Algorithm:Expand(#10 (+ 2) -10)
		Algorithm:Map(fn => Algorithm:Map(fn vals) fns)
	}
}