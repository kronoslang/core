Import Sort
Import Algorithm

Package Test {
	Basic() {
		Bitonic:Sort(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)
	}

	Invert() {
		Bitonic:Sort(16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1)
	}

	Reorder() {
		Use Algorithm
		is = Map(Math:Cos Expand(#16 (+ 0.3) 0))
		Bitonic:Sort(is)
	}
}