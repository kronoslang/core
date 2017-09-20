Import Algorithm

Package Seq {
	Type Sequence

	Cons(data accessor iterator) {
		Cons = Make(Sequence data accessor iterator)
	}

	Seq(state accessor simple-iterator) {
		iterator = (s a i) => Cons(simple-iterator(s) a i)
		Seq = Cons(state accessor iterator)
	}

	Data/Accessor/Iterator(seq) {
		(Data Accessor Iterator) = Break(Sequence seq)
	}

	First(seq) {
		(s a i) = Break(Sequence seq)
		First = a(s)
	}

	Rest(seq) {
		(s a i) = Break(Sequence seq)
		Rest = Require(i nil)
		Rest = i(s a i)
	}

	Force(seq) {
		(x xs) = seq
		Force = []
		Force = (x Force(xs))
	}

	Take(count series) {
		Take = Seq(
			(count series)
			(c s) => :First(s)
			(c s) => When(c > #1 (c - #1 :Rest(s))))
	}

	Drop(count series) {
		Drop = Algorithm:Iterate(count :Rest series)
	}

	Stride(step series) {
		Stride = 
			Nil?(series) : series 
			step == #1   : series 
			step == #2   :
				Cons(series :First
					(sr _) => Stride(#2 :Rest(:Rest(sr))))
				Cons(series :First
					(sr _) => Stride(step Algorithm:Iterate(step :Rest sr)))
	}

	Concat(a b) {
		Concat = Nil?(a) : b 
		  Cons(
			(a b)
			(a b)     => :First(a)
			((a b) _) => Concat(:Rest(a) b))
	}

	View(Xs) {
		bound = Arity(Xs)
		View = Lazy:Seq(
			(0i Xs)
			(i xs) => Select(xs i)
			(i xs) => (i + 1i xs))
	}
}

Package Fallback {
	First(seq) {
		First = Seq:First(seq)
	}

	Rest(seq) {
		Rest = Seq:Rest(seq)
	}	
}

Package Series{
	Arithmetic(initial increment) {
		Arithmetic = Seq:Seq(initial '_ (+ increment))
	}

	Geometric(initial factor) {
		Geometric = Seq:Seq(initial '_ (* factor))
	}

	Fibonacci = Seq:Seq(
		(1 1)
		(a b) => a
		(a b) => (b a + b))

	Naturals          = Arithmetic(0 1)
	Positive-Integers = Series:Arithmetic(1 1)
	Negative-Integers = Series:Arithmetic(-1 -1)
	Powers-of-Two 	  = Series:Geometric(2 2)
}

Package Lazy {	
	Count(xs) {
		Count = Arity(xs)
		Count = Arity(Seq:Force(xs))
	}

	Zip(sets...) {
		N = Count(sets...)

		forEach = f => Algorithm:Iterate(N ss => ('(f(:First(_)) Eval(ss :Rest(_)))) 'nil)
		rest = forEach(:Rest)
		rest-check = s => (rest(s) >> When(Algorithm:Some(Nil? _) nil _))

		Zip = Seq:Seq(sets... forEach(:First) rest)
	}

	Map(func set) {
		Map = Seq:Seq(set 'Eval(func :First(_)) :Rest)
	}

	Multi-Map(func sets...) {
		Multi-Map = Map(Curry(Apply func) Zip(sets...))
	}
}