Import Reflection

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

Function?(fn) #[Extend] {
	When(Class-of(fn) ==t :Closure True)
}

Package Fallback {
	Eval(fn arg...) #[Extend] {
		Eval = Handle(Closure:Call(fn arg...) Raise("Could not evaluate " fn " with arguments " arg...))
	}
}