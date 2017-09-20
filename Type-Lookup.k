Package Type-Lookup {
	Class-to-Package(inst) {
		cls = Class-Of(inst)
		String:Skip(String:Convert(cls) #1)
	}

	Function-Name(fn) {
		tag = Class-Of(fn)
		First(Break(tag fn))
	}

	Method-Name(obj fn) {
		String:Append(Class-to-Package(obj) String:Append(":" Function-Name(fn)))
	}

	Dispatch-Nullary(obj method) {
		fn = Resolve(Method-Name(obj method))
		fn(obj)
	}

	Dispatch(obj method args) {
		fn = Resolve(Method-Name(obj method))
		fn(obj args)	
	}
}

Infix.(inst message) {	
	Pair?(message) : Type-Lookup:Dispatch(inst message)
		Type-Lookup:Dispatch-Nullary(inst message) 
}
