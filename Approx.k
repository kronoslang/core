Import Algorithm
Import Math
Import Closure
Import Complex

Package Approx {
	Brief() {
		;; Numerical tricks to compute approximations of mathematical functions efficiently, with some loss of precision.
		nil
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
		;; Provides a polynomial cosine shape around 0 with a half-period within the range [-0.5, 0.5],
		;; diverging rapidly outside those bounds. The precision is 
		;; decided by `order`, an invariant constant.

		x1 = x - #0.25
		Cosine-Shape = x1 * Math:Horner-Scheme(x1 * x1 Cosine-Coefs(order))
	}

	Tanh(w) {
		;; Fast hyperbolic tangent approximation; useful for soft saturation.
		;; From https://www.musicdsp.org/en/latest/Other/238-rational-tanh-approximation.html
		
		x = Max(#-3 Min(#3 w))
		x * (27 + x * x) / (27 + 9 * x * x)
	}

	Package Faster {
		Brief() {
			;; Extremely fast, less precise routines
			;; ported from https://github.com/loony-bean/fastapprox-rs.
			nil
		}

		Log2(x) {
			;; Approximate base-2 logarithm of `x`
			Cast-Int(Coerce(Float x)) * 1.1920928955078125e-7 - 126.94259404
		}

		Log(x) {
			;; Approximate natural logarithm of `x`
			Cast-Int(Coerce(Float x)) * 8.2629582881927490e-8 - 87.989971088
		}

		Pow2(x) {
			;; Approximate power-of-two, as in `2^x`
			clipp = Max(-126 x)
			Cast-Float(Coerce(Int32 Math:Pow(#2 #23) * (clipp + #126.94269504)))
		}

		Pow(x p) {
			;; Approximate power function, `x^p`, by using the 
			;; approximations `Pow2` and `Log2` to compute 
			;; `Pow2(p * Log2(x))`

			Pow2(p * Log2(x))
		}

		Exp(p) {
			;; Approximate the exponential function using the `Pow2`
			;; approximation

			Pow2(#1.442695040 * p)
		}

		Sigmoid(x) {
			;; Approximate the sigmoid saturation function
			1 / (1 + Exp(Neg(x)))
		}

		Sinh(p) {
			0.5 * (Exp(p) - Exp(Neg(p)))
		}

		Cosh(p) {
			0.5 * (Exp(p) + Exp(Neg(p)))
		}

		Tanh(p) {
			;; Approximate the hyperbolic tangent
			-1 + 2 / (1 + Exp(-2 * p))
		}

		Sin-Period(x) {
			;; Approximate sine in the range [-Pi,Pi]
			four-over-pi = 1.2732395447351627
			four-over-pisq = 0.40528473456935109
			Q = 0.77633023248007499

			p = Cast-Int(0.22308510060189463)
			v = Cast-Int(x)

			qpprox = four-over-pi * x - four-over-pisq * x * Abs(x)
			qpprox * (Q + Math:Copy-Sign(0.22308510060189463 x) * qpprox)
		}

		Cos-Period(x) {
			;; Approximate cosine in the range [-Pi, Pi]
			two-over-pi = 0.63661977236758134
			P = 0.54641335845679634

			qpprox = 1 - two-over-pi * Abs(x)
			qpprox + P * qpprox * (1 - qpprox * qpprox)
		}

		Tan-Period(x) {
			;; Approximate tanget in the range [-Pi/2, Pi/2]
			Sin-Period(x) / Cos-Period(x)
		}
	}

	Package Fast {
		Brief() {
			;; Approximations for mathematical functions that balance
			;; precision and speed.
			;; ported from https://github.com/loony-bean/fastapprox-rs.
			nil
		}

		Log2(x) {
			;; Approximate base-2 logarithm
			vx = Cast-Int(x)
			mx = Cast-Float((vx & 0x007fffff) | 0x3f000000)
			y = Coerce(Float vx) * 1.1920928955078125e-7

			y - 124.22551499 - 1.498030302 * mx - 1.72587999 / (0.3520887068 + mx)
		}

		Log(x) {
			;; Approximate natural logarithm
			0.69314718 * Log2(x)
		}

		Pow2(x) {
			;; Approximate power-of-two, as in `2^x`
			offset = (x < 0) & 1
			clipp  = Max(-126 x)
			w = Coerce(Int32 clipp)
			z = clipp - Coerce(Float w) + offset 
			v = Math:Pow(#2 #23) * (clipp + 121.2740575 + 27.7280233 / (4.84252568 - z) - 1.49012907 * z)

			Cast-Float(Coerce(Int32 v))
		}

		Pow(x p) {
			;; Approximate `x^p` with the `Pow2` and `Log2` approximations.

			Pow2(p * Log2(x))
		}

		Exp(p) {
			;; Approximate the exponential function using the `Pow2`
			;; approximation

			Pow2(#1.442695040 * p)
		}

		Sigmoid(x) {
			;; Approximate the sigmoid saturation function
			1 / (1 + Exp(Neg(x)))
		}

		Sinh(p) {
			;; Approximate the hyperbolic sine
			0.5 * (Exp(p) - Exp(Neg(p)))
		}

		Cosh(p) {
			;; Approximate the hyperbolic cosine
			0.5 * (Exp(p) + Exp(Neg(p)))
		}

		Tanh(p) {
			;; Approximate the hyperbolic tangent
			-1 + 2 / (1 + Exp(-2 * p))
		}
	}
}