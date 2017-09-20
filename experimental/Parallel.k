Import Algorithm

Package Hylo {
	Type Seq
	Package Seq {
		Cons(state accessor iterator) {
			Cons = Make(Seq state accessor iterator)
		}

		State/Accessor/Iterator(sequence) {
			(State Accessor Iterator) = Break(Seq sequence)
		}

		Current(seq) {
			Current = Eval(Accessor(seq) State(seq))
		}

		Next(sequence) {
			Next = nil

			(x a i) = Break(Seq sequence)
			Next = Cons(i(x) a i)
		}
	}

	Expand(count iterator seed) {
		cur = (c s) => s
		nxt = (c s) => When(c > #1  (c - #1 iterator(s)))

		Expand = Seq:Cons((count seed) cur nxt)
	}

	Map(func data) {
		Map = Seq:Cons(data d => func(First(data)) Rest)

		(s a i) = (Seq:State(data) Seq:Accessor(data) Seq:Iterator(data))
		Map = Seq:Cons(s state => func(a(state)) i)
	}

	Zip(func a b) {
		Zip = Seq:Cons(
				(a b)
				((a as) (b bs)) => (a b)
				((a as) (b bs)) => (as bs)
			)
	}

	Vector-Reduce(func acc data) {
		r1 = data
		r2 = Seq:Next(r1)
		r3 = Seq:Next(r2)
		r4 = Seq:Next(r3)

		Vector-Reduce = Recur(func func(acc Vector:Pack(r1 r2 r3 r4)) Seq:Next(r4))
		Vector-Reduce = When(Equal-Type(data nil) acc)
	}

	Unordered-Reduce(func data) {
		Unordered-Reduce = :Algorithm:Reduce(func data)

		l1 = data
		l2 = Seq:Next(data)
		l3 = Seq:Next(l2)
		l4 = Seq:Next(l3)

		Unordered-Reduce = 
			Algorithm:Reduce(func
				Vector:Unpack(
					Vector-Reduce(func 
						Vector:Pack(
							Algorithm:Map(Seq:State l1 l2 l3 l4))
						Seq:Next(l4))))
	}
}

Package Fallback {
	First(seq) {
		First = Hylo:Seq:Current(seq)
	}

	Rest(seq) {
		Rest = Hylo:Seq:Next(seq)
	}	
}
