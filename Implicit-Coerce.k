Import Reflection
Import Algorithm
Import Closure
Import Coerce

Package Fallback {
	Coerce-Binary(a b) #[Pattern] {
		Coerce-Binary = (a Type-Conversion:Implicit(a b))
		Coerce-Binary = (Type-Conversion:Implicit(b a) b)
	}

	Binary-Op(func name a b) #[Extend] {
		Binary-Op = When(
			Not(Equal-Type(a b))
;				Explain-Constraint(
					func(Coerce-Binary(a b))
;					("Could not implictly coerce " a " and " b " to legal types for " name))
				)

	}

	Bad-Coerce(type data) {
		Bad-Coerce = Type-Conversion:Implicit(type data)
	}
}

And(a b) #[Extend] {
	When( True?(a) b
		  Nil?(a) a )	
}

Or(a b) #[Extend] {
	When( Nil?(a) b )
}

Package Type-Conversion {
	Implicit?(from to) {
		Implicit? =
			Equal-Type(from Constant) : True
			Equal-Type(from Int32) :
				(Equal-Type(to Float)  : True
				 Equal-Type(to Double) : True
				 Equal-Type(to Int64)  : True 
				 nil)
			Equal-Type(from Int64) :
				(Equal-Type(to Float)  : True
				 Equal-Type(to Double) : True 
				 nil)
			Equal-Type(from Float) :
				(Equal-Type(to Double) : True 
				 nil)
			nil

		Implicit? = When(Pair?(to) Recur(from First(to)))
		Implicit? = When(Pair?(from) Recur(First(from) to))
	}

	Implicit(type data) #[Pattern] {
		Implicit = When(
			Implicit?(data type) | Implicit?(Class-of(data) type) | Implicit?(Class-of(data) Class-of(type))
				Explicit(type data))
	}

	Upgrade(alternative data) {
		Upgrade = data
		Upgrade = Implicit(alternative data)
	}
}
