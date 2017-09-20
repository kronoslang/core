Import Exception
Import Algorithm

Package Type-Conversion {
	Coerce-Class(type data) {
		Coerce-Class =
			Equal-Type(type Float)  : Cvt-Float(data)
			Equal-Type(type Double) : Cvt-Double(data)
			Equal-Type(type Int32)  : Cvt-Int32(data)
			Equal-Type(type Int64)  : Cvt-Int64(data)
			Equal-Type(type 0)  	: Cvt-Float(data)
			Equal-Type(type 0d) 	: Cvt-Double(data)
			Equal-Type(type 0i)  	: Cvt-Int32(data)
			Equal-Type(type 0q)  	: Cvt-Int64(data)
			Equal-Type(type data)	: data
			Equal-Type(type Class-Of(data)) : data
			Equal-Type(type "")		: String:Convert(data)
			Throw:Invalid-Argument("Can't coerce " Class-Of(data) " to " Class-Of(type))

	}

	Native-Element-Type(data) {
		Native-Element-Type = data
		Native-Element-Type = First(Vector:Unpack(data))
	}

	Vector-Type(type) {
		Vector-Type = Class-Of(type)
		(ty width) = type
		Vector-Type = Require(width (ty width))
	}


	Explicit(type data) {
		Explicit = Invalid-Function()
		Explicit = Type-Conversion:Coerce-Class(type data)

		(ty width) = Vector-Type(type)  ; Vector class
		vecsrc = Vector:Unpack(data) ; Vector source
		Explicit = When(width == Arity(vecsrc) Coerce-Class(ty data))
		Explicit = When(Constant?(data) Vector:Broadcast(width Coerce-Class(ty data)))
		Explicit = When(Equal-Type(type data) data)
	}
}


Coerce(type data) {
	Coerce = Throw:Invalid-Argument("Can't coerce " Class-Of(data) " to " Class-Of(type))
	Coerce = Type-Conversion:Explicit(type data)
}

