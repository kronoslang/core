Import Algorithm

Package Math {
	Brief(documentation) {
		;; Mathematical functions, for hyperbolic transcendentals and polynomials.
		nil
	}

	Pi = Atan2(#1 #0) * #2
	E = Exp(#1)

	Tan(x) {
		;; Computes the tanget of 'x'
		Tan = Sin(x) / Cos(x)
	}

	Sinh(x) {
		;; Computes the hyperbolic sine of 'x'
		ex = Exp( Min(x #32) )
		Sinh = (ex * ex - #1) / (ex + ex)
	}

	Cosh(x) {
		;; Computes the hyperbolic cosine of 'x'
		ex = Exp( Min(x #32) )
		Cosh = (ex * ex + #1) / (ex + ex)
	}

	Tanh(x) {
		;; Computes the hyperbolic tangent of 'x'
		; Clamp x to avoid numeric problems
		e2x = Exp( Min(x + x #32) )
		Tanh = (e2x - #1) / (e2x + #1)
	}

	Coth(x) {
		;; Computes the hyperbolic cotangent of 'x'
		e2x = Exp( Min(x + x #32) )
		Coth = (e2x + #1) / (e2x - #1)
	}

	Sech(x) {
		;; Computes the hyperbolic secant of 'x'
		ex = Exp( Min(x #32) )
		Sech = (ex + ex) / (ex * ex + #1)
	}

	Csch(x) {
		;; Computes the hyperbolic cosecant of 'x'
		ex = Exp( Min(x #32) )
		Csch = (ex + ex) / (ex * ex - #1)
	}

	Copy-Sign(value sign) {
		;; changes the sign of 'value' to match 'sign'
		sv = Coerce(value sign)
		Abs(value) | Xor(Abs(sv) sv)
	}

	Horner-Scheme(x coefficients) {
		;; Evaluates a polynomial described by the set of 'coefficients' that correspond to powers of 'x' in ascending order. The evaluation is carried out according to the Horner scheme.
		Horner-Scheme = Algorithm:Fold((a b) => a + x * b coefficients)
	}

	Linear-Interpolation(h x0 x1) {
		;; Interpolate linearly between x0 an x1 as h ranges from 0 to 1.
		x0 + h * (x1 - x0)
	}

	Hermite-Interpolation(h x-1 x0 x1 x2) {
		;; Hermite interpolation between 'x0' and 'x1' as 'h' goes from 0 to 1, with further control points 'x-1' and 'x2' referring to past and future points.

		; adapted from musicdsp.org, C source attributed to Laurent De Soras
		c  = (x1 - x-1) * #0.5
		v  = x0 - x1
		w  = c + v
		a  = w + v + (x2 - x0) * #0.5
		bn = w + a

		((((a * h) - bn) * h + c) * h + x0)
	}

	Clamp(x low-bound high-bound) {
		;; Clamp the values of 'x' so that it will not go below 'low-bound' or above
		;; 'high-bound'

		Min(high-bound Max(low-bound x))
	}

	Mix(mix a b) {
		;; Weighted average of 'a' and 'b' according to ratio, so that 0 corresponds to 
		;; fully 'a', 1 to 'b' and 0.5 to an equal mix.

		Linear-Interpolation(Clamp(mix #0 #1) a b)
	}

	Binomial-Coef(n k:Constant!) {
		;; computes binomial coefficient for the pair `(n k)`

		Use Algorithm

		When(k ==t #0 
				#1 
			 k ==t #1
			 	n
			 Otherwise 
				Reduce(
					(p i) => p * (n + #1 - i) / i 
					n Rest(Count(k))))
	}

	Factorial(n:Constant!) {
		;; computes the factorial of 'n'

		x = Truncate(n)
		When(x > #1 
			 	x * Factorial(x - #1)
			 Otherwise 
			 	#1)
	}
}