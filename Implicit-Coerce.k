Import Reflection
Import Algorithm
Import Closure
Import Coerce

Package Fallback {
	Coerce-Binary(a b) {
		Coerce-Binary = (a Type-Conversion:Implicit(a b))
		Coerce-Binary = (Type-Conversion:Implicit(b a) b)
	}

	Binary-Op(func name a b) {
		Binary-Op = When(Not(Equal-Type(a b))
						 func(Coerce-Binary(a b)))
	}

	Bad-Coerce(type data) {
		Bad-Coerce = Type-Conversion:Implicit(type data)
	}
}

Package Type-Conversion {
	Implicit?(from to) {
		Implicit? = 
			Equal-Type(from Constant) : True
			Equal-Type(from Int32)     :
				(Equal-Type(to Float)  : True 
				 Equal-Type(to Double) : True 
				 Equal-Type(to Int64)  : True nil)
			Equal-Type(from Int64)    :
				(Equal-Type(to Float)  : True 
				 Equal-Type(to Double) : True nil)
			Equal-Type(from Float)    :
				(Equal-Type(to Double) : True nil)
			nil
	}

	Implicit(type data) {
		Implicit = When(
			Implicit?(data type) | Implicit?(Class-Of(data) type) | Implicit?(Class-Of(data) Class-Of(type))
				Explicit(type data))
	}
}
