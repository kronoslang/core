Import Math
Import Algorithm

Package Test {
	Copy-Sign-IEEE() {
		signs = [-3 0 5 -1i 100i 0i -5d -100d 7d #0 #3 #-1]
		values = Algorithm:Expand(#21 (+ 1) -10)
		Algorithm:Zip-With(Math:Copy-Sign values signs)
	}
}