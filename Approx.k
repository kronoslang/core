Import Algorithm
Import Math
Import Closure
Import Complex

Package Approx {
	Brief() {
		;; Numerical tricks to compute approximations of mathematical functions quickly.
		()
	}

	Pi = #3.14159265359

	Cosine-Coefs(order) {
		exp-iter = (index num denom) => (
			index + #1      	; next coefficient index
			num * #2 * Pi    	; next numerator 
			denom * index)  	; next denominator 

		flip-sign = (index num denom) => (index Neg(num) denom)

		sine-iter = x => flip-sign(exp-iter(exp-iter(x)))

		Cosine-Coefs = Algorithm:Map(
				(index num denom) => (num / denom)
				Algorithm:Expand(order sine-iter (#2 #-2 * Pi #1)))
	}

	Cosine-Shape(x order) {
		;; Provides a cosine shape around 0 with a half-period within the range [-0.5, 0.5],
		;; diverging rapidly outside those bounds.

		x1 = x - #0.25
		Cosine-Shape = x1 * Math:Horner-Scheme(x1 * x1 Cosine-Coefs(order))
	}

	Tanh(w) {
		;; Fast hyperbolic tangent approximation; useful for soft saturation.
		;; From https://www.musicdsp.org/en/latest/Other/238-rational-tanh-approximation.html
		
		x = Max(#-3 Min(#3 w))
		x * (27 + x * x) / (27 + 9 * x * x)
	}

	Log2-Integer(x) {
		;; Computes an integer-valued, truncated logarithm of base 2. That is,
		;; finds the largest power of two less than or equal to 'x'.

		BitShiftRight(Cast-Int(Coerce(Float x)) 23i) - 127i
	}

	Piecewise-Log2(x) {
		;; Computes an approximation of base 2 logarithm by interpolating
		;; between two powers of 2 below and above 'x'.

		bit-mask = Cast-Int(Coerce(Float x))

		exponent = bit-mask & 0xff800000
		mantissa = bit-mask & 0x007fffff

		l0 = Log2-Integer(x)

		l0 + (mantissa + 0 + (x - x)) * Math:Pow(#2 #-23)
	}

	Exp(x n) {
		;; Computes `e^x` with a polynomial series of degree `n`
		Use Algorithm

		coefs = Map(k => #1 / Math:Factorial(k) Count(n #0))

		Math:Horner-Scheme(x coefs)
	}

	Artanh-Log(z n) {
		Use Algorithm

		z-z = (z - #1) / (z + #1)
		coefs = Map((#1 /) Count(n #1 #2))
		#2 * z-z * Math:Horner-Scheme(z-z coefs)
	}

	Log(z) {
		y = Piecewise-Log2(z) / Piecewise-Log2(Math:E)

		A = z * Math:Exp(Neg(y))

		y + Artanh-Log(A #7)
	}	


}

