Import Algorithm
Import Reflection

Package Interval {
	Brief() {
		;; Declare and track intervals (known ranges) of values.
		nil
	}

	Type Constrained-Value

	Cons(value min max) {
		Cons = Make(Constrained-Value value min max)
		Cons = When(Constant?(value) value)
	}

	Constrain(value min max) {
		;; Constrains `value` to range `[min, max]`
		Cons(Max(min Min(max value)) min max)
	}

	Interval(v) #[Pattern] {
		(_ m x) = Break(Constrained-Value v)
		Constant?(v) : (v v) (m x)
	}

	Value(v) {
		Value = v
		Value = First(Break(Constrained-Value v))
	}

	Rescale(value new-min new-max) {
		Rescale = Constrain(new-min + (value + #1) * (new-max - new-min) / #2 new-min new-max)

		(v m x) = Break(Constrained-Value value)
		Rescale = Cons(new-min + (v - m) * (new-max - new-min) / (x - m))
	}

	Add(a b) {
		av = Value(a)
		bv = Value(b)
		(am ax) = Interval(a)
		(bm bx) = Interval(b)
		Cons(av + bv am + bm ax + bx)
	}

	Sub(a b) {
		av = Value(a)
		bv = Value(b)
		(am ax) = Interval(a)
		(bm bx) = Interval(b)
		Cons(av - bv am - bx bm - ax)
	}

	Mul(a b) {
		Use Algorithm
		av = Value(a)
		bv = Value(b)
		(am ax) = Interval(a)
		(bm bx) = Interval(b)

		prods = [am * bm
				 am * bx
				 ax * bm
		 		 ax * bx]

		Cons(av * bv Max(prods) Min(prods))
	}
}

Constrained-Interval?(v) {
	Constrained-Interval? = nil
	Constrained-Interval? = Require(Interval:Interval(v) True)
}

Package Fallback {
	Binary-Op(func name a b) #[Extend] {
		Use Algorithm
		overloads = [ (Add Interval:Add)
					  (Mul Interval:Mul)
					  (Sub Interval:Sub) ]

		(key overload) = Algorithm:Some((k o) => (k ==t func) overloads)

		ai = Interval:Interval(a)
		bi = Interval:Interval(b)

		Binary-Op = Require((ai bi) overload(a b))
	}
}

Package Type-Conversion {
	Explicit(type data) #[Extend] {
		;; drop interval information
		(v _) = Break(Interval:Constrained-Value data)
		Explicit = Recur(type v)
	}

	Implicit(type data) #[Extend] {
		; Intervals are implicitly lost when coercing to unbound values
		(v _) = Break(Interval:Constrained-Value data)
		v
	}
}
