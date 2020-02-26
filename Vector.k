Import Algorithm

Vector?(v) {
	Class-of(v) ==t Vector:Vector
}

Constraints:Vector!(v) #[Pattern] {
	;; Satisfy constraint when 'v' is a vector
	When(Vector?(v) v)
}

Package Vector {
	Type Vector
	Cons(elements...) {
		;; Combine 'elements...' into a vector
		Cons = Make(Vector List-to-Tuple(elements...))
		Cons = Make(Vector Vector:Pack(elements...))
	}

	Vectorize(elements...) {
		;; If `elements...` is a tuple, turn it into a vector.
		;; Otherwise return as-is.

		es = List-to-Tuple(elements...)

		When(Pair?(es)
				Cons(es)
			 Otherwise
				es)
	}

	Explode(v) {
		;; Separate elements in vector 'v'
		elts = Break(Vector v)
		Explode = elts
		Explode = Vector:Unpack(elts)
	}

	Packed?(v) {
		Packed? = nil
		(e w) = Class-of(Break(Vector v))
		Packed? = Require(w True)
	}

	Width(v) {
		;; Number of elements in vector 'v'
		Width = Arity(Explode(v))
	}

	Zip-Op(op v1 v2) {
		w1 = Width(v1)
		w2 = Width(v2)
		p1 = Packed?(v1)
		p2 = Packed?(v2)

		Cons(Algorithm:Zip-With(op
				When((w1 ==t w2) & (p1 ==t p2)
						(Break(Vector v1) Break(Vector v2))
					 Otherwise
					 	(Explode(v1) Explode(v2)))))
	}

	Zip3-Op(op v1 v2 v3) {
		w1 = Width(v1)
		w2 = Width(v2)
		w3 = Width(v3)
		p1 = Packed?(v1)
		p2 = Packed?(v2)
		p3 = Packed?(v3)

		Cons(Algorithm:Zip3-With(op
				When((w1 ==t w2) & (p1 ==t p2) & (w1 ==t w3) & (p1 ==t p3)
						(Break(Vector v1) Break(Vector v2) Break(Vector v3))
					 Otherwise
					 	(Explode(v1) Explode(v2) Explode(v3)))))
	}

	Tuple-Binary-Op(op t1 t2) #[Pattern] {
		When(Pair?(t1) & Pair?(t2)
			 	op(Vector:Cons(t1) Vector:Cons(t2))
			 Pair?(t1)
			 	op(Vector:Cons(t1) t2)
			 Pair?(t2)
			 	op(t1 Vector:Cons(t2)))
	}

	Map-Op(op v) {
		Cons(Algorithm:Map(op Break(Vector v)))
	}

	Broadcast-To(vector scalar) {
		;; Result is structurally similar to 'vector', but all elements
		;; are 'scalar'.
		Broadcast-To = Cons(Algorithm:Map({ scalar } Explode(vector)))
		Broadcast-To =
			When(Vector?(scalar)
				Cons(Algorithm:Zip-With(Coerce Explode(vector) Explode(scalar))))
	}

	Horizontal(fn v) {
		;; Apply binary operator 'fn' horizontally to reduce the vector to a single element.
		;; For example, to add all vector elements, use `Horizontal(Add vector)`
		Algorithm:Reduce(fn Explode(v))
	}

	Indices(count) {
		;; Produces an index vector with 'count' elements, starting from 0 and increasing by one.
		Cons(Algorithm:Expand(count (+ 1) 1))
	}

	Indices(count start) #[Extend] {
		;; Producs an index vector with 'count' elements, starting from 'start' and increasing by one.
		Cons(Algorithm:Expand(count (+ #1) start))
	}

	Indices(count start step) #[Extend] {
		;; Produces an index vector with 'count' elements, starting from 'start' and increasing by 'step'.
		Cons(Algorithm:Expand(count (+ step) start))
	}

	Repeat(count value) {
		;; Produces a vector with 'count' elements, each set to 'value'.
		Cons(Algorithm:Expand(count '_ value))
	}

	Ones(count) {
		;; Produces a vector with 'count' elements, each set to 1.
		Repeat(count 1)
	}

	Split(vector) {
		;; Splits `vector` into a tuple of two smaller vectors
		;; half the width. If the original width is odd, the first
		;; vector will be smaller.

		(f s) = Algorithm:Split(Explode(vector))
		(Vectorize(f) Vectorize(s))
	}

	Concat(a b...) {
		;; Concatenates elements in vectors, tuples or scalars
		;; into a vector.

		ae = When(Vector?(a) Explode(a)
				  Otherwise a)

		be = When(Vector?(b...) Explode(b...)
				  Otherwise b...)

		Concat = Cons(Algorithm:Concat(ae be))

		(b1 bs) = b...
		Concat = Recur(a Concat(b1 bs))
	}
}

Package Fallback {
	Binary-Op(func name a b) #[Extend] {
		overload = Curry(Vector:Zip-Op func)

		Binary-Op = When((Class-of(a) ==t Vector:Vector) &
						 (Class-of(b) ==t Vector:Vector)
						 	overload(a b)
						 (Class-of(a) ==t Vector:Vector)
						 	overload(a Vector:Broadcast-To(a b))
						 (Class-of(b) ==t Vector:Vector)
						 	overload(Vector:Broadcast-To(b a) b))
	}

	Unary-Op(func name a) #[Extend] {
		When((Class-of(a) ==t Vector:Vector)
				Vector:Map-Op(func a))
	}
}

Package Type-Conversion {
	Explicit(type data) #[Extend] {
		When(Vector?(type) & Vector?(data)
				 Vector:Zip-Op(Coerce type data)
			 Vector?(type)
			 	 Vector:Cons(
			 	 	Algorithm:Map(e => Coerce(e data)
			 	 		Vector:Explode(type)))
			 Vector?(data)
			 	Vector:Cons(
			 	 Algorithm:Map(Curry(Coerce type)
			 	 			   Break(Vector:Vector data))))
	}

	Implicit?(type data) #[Extend] {
		elts = Break(Vector:Vector data)
		Algorithm:Every(Curry(Implicit? type) elts)
	}
}

Ternary-Select(pred t f) #[Extend] {
	pv? = Class-of(pred) ==t Vector:Vector
	tv? = Class-of(t) ==t Vector:Vector
	fv? = Class-of(f) ==t Vector:Vector

	vec = pv? : pred
		  tv? : t
		  fv? : f
		  nil

	Ternary-Select = When(Not(Nil?(vec))
		When(Not(pv?) Recur(Vector:Broadcast-To(vec pred) t f)
			 Not(tv?) Recur(pred Vector:Broadcast-To(vec t) f)
			 Not(fv?) Recur(pred t Vector:Broadcast-To(vec f))
			 ((pred ==t t) & (pred ==t f))
			 	Vector:Cons(
			 		Algorithm:Zip3-With(:Ternary-Select
			 			Break(Vector:Vector pred)
			 			Break(Vector:Vector t)
			 			Break(Vector:Vector f)))
			 Otherwise
			 	Vector:Cons(
			 		Algorithm:Zip3-With(:Ternary-Select
			 			Vector:Explode(pred)
			 			Vector:Explode(t)
			 			Vector:Explode(f)))))
}

Select(buffer index) #[Extend] {
	Vector:Cons( 
		Algorithm:Map(
			i => Select(buffer i) 
			Vector:Explode(Constraints:Vector!(index))))
}

Select-Wrap(buffer index) #[Extend] {
	Vector:Cons( 
		Algorithm:Map(
			i => Select-Wrap(buffer i) 
			Vector:Explode(Constraints:Vector!(index))))
}

Real?(vector:Vector!) #[Extend] {
	Recur(First(Vector:Explode(vector)))
}

Scalar?(vector:Vector!) #[Extend] {
	Recur(First(Vector:Explode(vector)))	
}

Integer?(vector:Vector!) #[Extend] {
	Recur(First(Vector:Explode(vector)))	
}

Single-Precision?(vector:Vector!) #[Extend] {
	Recur(First(Vector:Explode(vector)))	
}

Double-Precision?(vector:Vector!) #[Extend] {
	Recur(First(Vector:Explode(vector)))	
}


Infix+v = Curry(Vector:Tuple-Binary-Op Vector:Add)
Infix-v = Curry(Vector:Tuple-Binary-Op Vector:Sub)
Infix*v = Curry(Vector:Tuple-Binary-Op Vector:Mul)
Infix/v = Curry(Vector:Tuple-Binary-Op Vector:Div)
Infix>v = Curry(Vector:Tuple-Binary-Op Vector:Greater)
Infix<v = Curry(Vector:Tuple-Binary-Op Vector:Less)
Infix>=v = Curry(Vector:Tuple-Binary-Op Vector:Greater-Equal)
Infix<=v = Curry(Vector:Tuple-Binary-Op Vector:Less-Equal)
Infix!=v = Curry(Vector:Tuple-Binary-Op Vector:Not-Equal)
Infix&v = Curry(Vector:Tuple-Binary-Op Vector:And)
Infix|v = Curry(Vector:Tuple-Binary-Op Vector:Or)
Infix^v = Curry(Vector:Tuple-Binary-Op Vector:Xor)
