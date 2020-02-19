Import Algorithm
Import Reflection

Package Vector {
	Type EVec

	Pack(elements...) {
		(e es) = elements...

		primitive? = Float?(e) | Double?(e) | Int?(e)

		When(Algorithm:Every((e ==t) es) & primitive?
			 Make(EVec elements...))
	}

	Unpack(vector) {
		Break(EVec vector)
	}

	Broadcast(width element) {
		Pack(Algorithm:Expand(width { arg } element))
	}
}

Package Fallback {
	Binary-Op(func name a b) {
		as = Vector:Unpack(a)
		bs = Vector:Unpack(b)
		Vector:Pack(Algorithm:Zip-With(func as bs))
	}

	Unary-Op(func name a) {
		as = Vector:Unpack(a)
		Vector:Pack(Algorithm:Map(func as))
	}
}