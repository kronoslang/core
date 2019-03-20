Type Closure

Package Closure {
	Cons(func with) {
		Cons = Make(:Closure func with)
	}

	Call(closure args) #[Pattern]
	{
		(fn curried) = Break(:Closure closure)
		Call = fn(curried args)
	}
}

Curry(func a) {
	Curry = Closure:Cons(func a)
}

Package Fallback {
	Eval(fn arg...) #[Extend] {
		unbound = Class-Of(Resolve("an impossible symbol"))
		(unbound-sym _) = Break(unbound fn)

		Eval = Raise(unbound-sym " is not defined")
		Eval = Closure:Call(fn arg...)
	}
}
