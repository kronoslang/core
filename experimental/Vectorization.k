Import Algorithm
Import Reflection

Package Vectorize {
	Package Internal {
		Flat-First(vector) {
			Flat-First = a

			(a as) = vector
			Flat-First = recur(a)
		}

		As-Tuple(list) {
			As-Tuple = Algorithm:Fold((a b) => (a b) list)
		}
	}

	Struct-of-Arrays(array-of-structs) {
		(s ss) = array-of-structs

		Struct-of-Arrays = Reflection:Is-Any-Of(s Float Double Int32 Int64) :
							Vector:Pack(array-of-structs)
							array-of-structs

		(a b) = s
		Struct-of-Arrays = ( Recur(a Algorithm:Map(First ss))
							 Recur(b Algorithm:Map(Rest  ss)) )

		ut = Class-Of(s)
		Struct-of-Arrays = Make(ut 
			Recur(Break(ut s) 
				  Algorithm:Map(x => Break(ut x) ss)))
	}

	Package Internal {
		Vector-Size(soa) {
			Vector-Size = nil

			Vector-Size = Arity(Vector:Unpack(soa))

			(a b) = soa
			(as bs) = (Recur(a) Recur(b))
			Vector-Size = as == nil  : bs
						  bs == nil  : as
						  as == bs	 : as
						  Invalid-Function()

			Vector-Size = Recur(Break(Class-Of(soa) soa))
		}

		Nth(idx vector) {
			Nth = idx > #1 		: Recur(idx - #1 Rest(vector))
				  Atom?(vector) : vector
				  First(vector)
		}

		Extract-Struct(soa idx) {
			Extract-Struct = soa

			(a b) = soa
			Extract-Struct = (Recur(a idx) Recur(b idx))

			ut = Class-Of(soa)
			Extract-Struct = Make(ut Recur(Break(ut soa) idx))

			Extract-Struct = Nth(idx Vector:Unpack(soa))
		}
	}

	Array-of-Structs(struct-of-arrays) {
		vecwidth = Internal:Vector-Size(struct-of-arrays)

		indices = Algorithm:Expand(vecwidth x => x + #1 #1)

		Array-of-Structs = Algorithm:Map(i => Internal:Extract-Struct(struct-of-arrays i) indices)
	}

	Map(func vector) {
		Map = Algorithm:Map(func vector)

		(i1 i2 i3 i4 is) = vector
		(o1 o2 o3 o4 _) = Array-of-Structs(Eval(func Struct-of-Arrays[i1 i2 i3 i4]))
		Map = (o1 o2 o3 o4 Recur(func is))
	}
}