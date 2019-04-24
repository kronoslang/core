Import Vector
Import Gen
Import Filter

Package Test {
	Vectorized-Gen() {
		Use Vector
		vibr = 50 * Gen:Sin(1)
		Horizontal((+) Gen:Sin(Cons(220 330 440 550 660 770) + vibr)) / 7
	}

	Vectorized-Filter() {
		Use Vector
		n = Gen:Noise()
		bw = 100 * Gen:Phasor(0.2)
		Horizontal((-) Filter:Resonator(n Cons(330 440 550 660 990) bw)) * #0.2
	}

	Coerce() {
		[
			Vector:Cons(1 2 3) + Vector:Cons(2d 5d)
			Vector:Cons(1 2 3 4) * #100
			Vector:Cons(1 2d 3i) / Vector:Cons(10 20 30)
			Vector:Cons(1 2 3 4 5 6 7 8) * Vector:Cons(2i 3q)
			Vector:Cons(3i 4i 5i) * Vector:Cons(10 100)
		]
	}

	Mixed-Rate() {
		Use Vector
		f = Control:Param("freq" 440)
		:Coerce(Float Horizontal(Add Gen:Tri(Cons(330d 440 550 f f))))
	}

	Selection() {
		Use Vector[Cons Ones Repeat]
		Use Algorithm[Expand]
		[
			Ternary-Select(
				Cons(Expand(#10 (+ 1) 5)) > Cons(Expand(#10 (* 2) 0.5))
				Repeat(#10 1)
				Repeat(#10 0))
			Ternary-Select(
				Cons(Expand(#11 (+ 1d) 5)) > Cons(Expand(#10 (* 2d) 0.5))
				Repeat(#9 1)
				Repeat(#8 0d))
		]
	}

	Big-Vector() {
		harmonics = Vector:Indices(#200) * 2 - 1
		partials = Gen:Sin(harmonics * 40)
		Vector:Horizontal((+) partials / harmonics)
	}

	Big-Mixed-Vector() {
		harmonics = Vector:Cons(1d Algorithm:Expand(#199 (+ 1) 2))
		partials = Gen:Sin(harmonics * 40)
		:Coerce(Float Vector:Horizontal((+) partials / harmonics))
	}
}