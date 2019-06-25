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

	Interpolate(fn) {
		;; Composes a function that, when called with argument `x`, calls `fn(x)` and `fn(x+1)`, and returns a linearly interpolated value weighted by the fraction of `x`.
		;; This can produce a linear breakpoint function from a discrete-valued, 'stair-case' `fn`.

		{ Math:Linear-Interpolation(
			Fraction(arg)
			fn(arg)
			fn(arg + #1)) }
	}

	Interpolate-Hermite(fn) {
		;; Composes a function that, when called with argument `x`, calls `fn` with arguments `x - 1, x, x + 1, x + 2`.
		;; The results are used to compute a Hermite polynomial interpolation between the values at `x` and `x + 1`. The additional
		;; control points provide higher quality interpolation.

		{ Math:Hermite-Interpolation(
			Fraction(arg)
			Algorithm:Map(fn arg - #1 arg arg + #1 arg + #2)) }
	}

	Sample(xs...) {
		;; Given a list `xs...`, returns a function that, given an argument `i`, returns
		;; the `i`:th element in `xs...`.
		{ Select(xs... arg) }
	}

	Sample-Cyclic(xs...) {
		;; Given a list `xs...`, returns a function that, given an argument `i`, returns
		;; the `i`:th element in `xs...`. The list is extended in an infinite cycle, both
		;; beyond the count of the original elements and also below index 0.

		{ Select-Wrap(xs... arg) }
	}

	Wavetable(xs...) {
		;; Returns a function that, given an argument 'x', remaps
		;; it to a periodic wavetable specified by `xs...`. The wavetable
		;; has a period of 1.

		{ Select-Wrap(xs... Arity(xs...) * arg) }
	}
}