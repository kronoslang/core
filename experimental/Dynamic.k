Import Exception

Type Dynamic-Function

Package Dynamic {
	Cons(fn num-args) {
		;; Constructs a function that can dispatch on tagged union types for the first 'num-args' arguments.
		Cons = Make(:Dynamic-Function fn num-args)
	}

	Perform-Dispatch(counter fn args) {
		(a as) = args

		Perform-Dispatch = Recur(counter - #1 'fn(args) nil)
		Perform-Dispatch = Recur(counter - #1 'fn(a) as)

		Perform-Dispatch = Dispatch(dyn => Perform-Dispatch(counter - #1 'fn(dyn _) nil) args)
		Perform-Dispatch = Dispatch(dyn => Perform-Dispatch(counter - #1 'fn(dyn _) as) a)

		Perform-Dispatch = When(counter <= #0 Throw:Type-Error("Dynamic function call resulted in a possible type error"))
		Perform-Dispatch = When(counter <= #0 fn(Debug-Trace("dyn " args)))
	}

	Eval(fn args) {
		Try-Dispatch = Reject-All-Forms
		Eval = Dispatch(fn args)

		(b1 b2) = args
		Eval = Dispatch('fn(_ b2) b1)
		Eval = Dispatch('fn(b1 _) b2)

		(c1 c2 c3) = args
		Eval = Dispatch('fn(c1 _ c3) c2)
		Eval = Dispatch('fn(c1 c2 _) c3)

		(d1 d2 d3 d4) = args
		Eval = Dispatch('fn(d1 d2 _ d4) d3)		
	}
}

Package Fallback {
	Eval(dfn args) {
		(fn num) = Break(Dynamic-Function dfn)
		Eval = Dynamic:Eval(fn args)
	}

	Unary-Op(fn a) {
		Unary-Op = Dispatch(fn a)
	}

	Binary-Op(fn a b) {
		Binary-Op = Dynamic:Eval(fn a b)
	}
}