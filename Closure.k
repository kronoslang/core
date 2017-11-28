Type Closure

Package Closure{
	Cons(func with){
		Cons = Make(:Closure (func with))
	}

	Call(cfunc args)
	{
		(Func CurryArg) = Break(:Closure cfunc)
		Call = Func(CurryArg args)
	}
}

Curry(func a) {
	Curry = Closure:Cons(func a)
}

Package Fallback {
	Eval(func argument)	{
		unbound = Class-Of(Resolve("an impossible symbol"))
		(unbound-sym _) = Break(unbound func)

		Eval = Raise("Can not evaluate " func " with argument " argument)
		Eval = Raise(unbound-sym " is not defined")
		Eval = Closure:Call(func argument)
	}	
}
