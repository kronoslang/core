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
}