Import Algorithm
Import Math
Import Closure
Import Complex

Package Approx {

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
		x1 = x - #0.25
		Cosine-Shape = x1 * Math:Horner-Scheme(x1 * x1 Cosine-Coefs(order))
	}

	Tanh(w) {
		;; Fast hyperbolic tangent approximation; useful for soft saturation.
		;; From https://www.musicdsp.org/en/latest/Other/238-rational-tanh-approximation.html
		
		x = Max(#-3 Min(#3 w))
		x * (27 + x * x) / (27 + 9 * x * x)
	}

}

