Import Algorithm
Import Math

Package Function {
	Brief() {
		;; Utilities to compose functions and adjust their behavior
		nil
	}

	Pipeline(fns...) {
		;; Composes the functions in `fns...` in a chain. The initial argument
		;; is transformed by each successive function and used as the argument
		;; to the next function, in sequence.
		argument => Algorithm:Reduce((x f) => f(x) argument fns...)
	}

	Compose(fns...) {
		;; Composes the functions in 'fns...' in a chain. The initial argument
		;; is passed to the last function in the list, and its return value
		;; is passed as the argument to the second-last function. Similiar
		;; transformation is performed by each function on the list, from back
		;; to front.
		Pipeline(Algorithm:Reverse(fns...))
	}

	Juxtapose(fns...) {
		;; Composes a function that passes its argument to all functions in `fn-list`, returning the results in a list.
		argument => Algorithm:Map(fn => fn(argument) fns...)
	}

	Wrap-LERP(fn) {
		;; Wraps `fn` in linear interpolation: returns a function that, when called with argument `x`,
		;; calls `fn(x)` and `fn(x + #1)`, interpolating linearly between them, weighted by the fraction
		;; of `x`.
		;; This can produce a linear breakpoint function from a discrete-valued, 'stair-case' `fn`.

		{ Math:Linear-Interpolation(
			Fraction(arg)
			fn(arg)
			fn(arg + #1)) }
	}

	Wrap-Hermite(fn) {
		;; Wraps `fn` in Hermite interpolation: returns a function that, when called with argument `x`,
		;; calls `fn` with four sample points ranging from `x - #1` to `x + #2`, and interpolates between
		;; the values at `x` and `x + #1` according to the fraction of `x`. The additional sample points
		;; are used to produce a smoother curve.

		{ Math:Hermite-Interpolation(
			Fraction(arg)
			fn(arg - #1)
			fn(arg)
			fn(arg + #1)
			fn(arg + #2)) }
	}

	Table(xs...) {
		;; Given a list `xs...`, returns a function that, given an argument `i`, returns
		;; the `i`:th element in `xs...`.
		{ Select(xs... arg) }
	}

	Table-Cyclic(xs...) {
		;; Given a list `xs...`, returns a function that, given an argument `i`, returns
		;; the `i`:th element in `xs...`. The list is extended in an infinite cycle, both
		;; beyond the count of the original elements and also below index 0.

		{ Select-Wrap(xs... arg) }
	}

	Table-Period(xs...) {
		;; Given a list of `xs..., returns a function that cycles through them
		;; during each interval between integers with linear interpolation. 
		;; Suitable for waveshaping a phasor.
		x => Eval( Wrap-LERP(Table-Cyclic(xs...)) x * Arity(xs...) )
	}

	Table-Period-Smooth(xs...) {
		;; Given a list of `xs..., returns a function that cycles through them
		;; during each interval between integers with polynomial Hermite interpolation. 
		;; Suitable for waveshaping a phasor.
		x => Eval( Wrap-Hermite(Table-Cyclic(xs...)) x * Arity(xs...) )
	}
}