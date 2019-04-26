Import Algorithm

Package Math {
	Brief(documentation) {
		;; Mathematical functions, for hyperbolic transcendentals and polynomials.
		nil
	}

	Pi = #2 * Atan2(#0 #1)

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
}