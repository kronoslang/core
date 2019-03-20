Import Algorithm

Vector?(v) {
	Class-Of(v) ==t Vector:Vector
}

Constraints:Vector!(v) #[Pattern] {
	;; Satisfy constraint when 'v' is a vector
	When(Vector?(v) v)
}

Package Vector {
	Type Vector
	Cons(elements...) {
		;; Combine 'elements...' into a vector
		Cons = Make(Vector elements...)
		Cons = Make(Vector Vector:Pack(elements...))
	}

	Explode(v) {
		;; Separate elements in vector 'v'
		elts = Break(Vector v)
		Explode = elts
		Explode = Vector:Unpack(elts)
	}

	Packed?(v) {
		Packed? = nil
		(e w) = Class-Of(Break(Vector v))
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
		e1 = Break(Vector v1)
		e2 = Break(Vector v2)
		Zip-Op = Cons(Algorithm:Zip-With(op
					When((w1 ==t w2) & (p1 ==t p2)
							(Break(Vector v1) Break(Vector v2))
						 Otherwise
						 	(Explode(v1) Explode(v2)))))
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
		Cons(Algorithm:Map(e => Coerce(e scalar) Explode(vector)))
	}

	Horizontal(fn v) {
		Algorithm:Reduce(fn Explode(v))
	}
}

Package Fallback {
	Binary-Op(func name a b) #[Extend] {
		overload = Curry(Vector:Zip-Op func)

		Binary-Op = When((Class-Of(a) ==t Vector:Vector) &
						 (Class-Of(b) ==t Vector:Vector)
						 	:Eval(overload a b)
						 (Class-Of(a) ==t Vector:Vector)
						 	:Eval(overload a Vector:Broadcast-To(a b))
						 (Class-Of(b) ==t Vector:Vector)
						 	:Eval(overload Vector:Broadcast-To(b a) b))
	}

	Unary-Op(func name a) #[Extend] {
		When((Class-Of(a) ==t Vector:Vector)
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
			 	 		Vector:Explode(type))))
	}
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
