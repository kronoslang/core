Import Actions
Import Type-Lookup

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
		Do( id <- Actions:Start( { Object(size element) } )
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
