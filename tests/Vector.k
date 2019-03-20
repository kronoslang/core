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
}