Import Actions
Import Type-Lookup

Type Register 
Package Register {
	Object(element) {
		new = Control:Param("set" element)
		Select([new] Control:Param("get" 0i))
	}

	Cons(element) {
		Actions:Do( id <- Actions:Start( { Object(element) } )
			Make(:Register id element) )
	}

	Destruct(reg) {
		(id el) = Break(:Register reg)
		Actions:Stop(id)
	}

	Get(reg) {
		(id el) = Break(:Register reg)
		Actions:Send-To(id "get" 0i)
	}

	Set(reg val) {
		(id el) = Break(:Register reg)
		Actions:Send-To(id "set" Coerce(el val))
	}
}

Type Counter 
Package Counter {
	Object(element) {
		counter = z-1(element new)
		new = counter + Control:Param("inc" element - element)
		new
	}

	Cons(element) {
		Actions:Do(
			id <- Actions:Start( { Object(element) })
			Make(:Counter id element))
	}

	Destruct(counter) {
		(id el) = Break(:Counter counter)
		Actions:Stop(id)
	}

	Increment(counter delta) {
		(id el) = Break(:Counter counter)
		Actions:Send-To(id "inc" Coerce(el delta))
	}
}

Type Array
Package Array {
	Update(list index value) {
		Update = When(Nil?(list) nil)

		(x xs) = list
		xx     = Ternary-Select(index == #0 value x)
		Update = (xx Recur(xs index - #1 value))
	}

	Object(size element) {
		(w x) = Control:Param("set" 0i element)
		buf   = Update(z-1(Algorithm:Expand(size 'element element) buf) w x)
		Select-Wrap(buf Control:Param("get" 0i))
	}

	Cons(size element) {
		Actions:Do( id <- Actions:Start( { Object(size element) } )
			Make(:Array id) )
	}

	Destruct(array) {
		Actions:Stop(Break(:Array array))
	}

	Get(array index) {
		Get = Actions:Send-To(array "get" Coerce(Int32 index))
	}

	Set(array index new-value) {
		Set = Actions:Send-To(array "set" Coerce(Int32 index) new-value)
	}
}
