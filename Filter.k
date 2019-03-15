Import Algorithm
Import Complex
Import IO

Type Filter
Package Filter {
	Cons(designer-fun) {
		Cons = Make(Filter designer-fun)
	}

	Designer(flt) {
		Designer = Break(Filter flt)
	}

	Integrate(sig leak) {
		y1 = z-1(sig - sig y1 * leak + sig)
		Integrate = y1
	}

	Convolve(sig coefs) {
		;; Convolves 'sig'nal with a FIR filter consisting of coefficients in 'coefs'. The length of the list determines the order of the filter. The coefficients are arranged from low to high order.
		Convolve = Algorithm:Fold(
			(c cs) => sig * c + z-1(cs * #0 cs)
			coefs)
	}

	DF-I(sig filter) {
		;; Apply 'filter' to 'sig'nal. This function designs the filter according to the
		;; sample rate of 'sig'.
		design = Designer(filter)
		(fir iir) = design(Interval-of(sig))

		iir-part = sig - z-1(sig - sig  Filter:Convolve(iir-part iir))
		DF-I = Convolve(iir-part fir)
	}

	DF-II(sig filter) {
		;; Apply 'filter' to 'sig'nal. This function designs the filter according to the
		;; sample rate of 'sig'. The delay lines in FIR and IIR parts of the filter are
		;; commuted.
		Use Algorithm

		design = Designer(filter)
		(fir iir) = design(Reactive:Interval-of(sig))

		deduce-type = Reduce(Mul sig Concat(fir iir))
		zero   	 = deduce-type - deduce-type
		zeroes 	 = Expand(Max(Arity(fir) - #1  Arity(iir)) 'zero zero)
		taps   	 = (sig Accumulate((t z) => z-1(z t + zero)
								   z-1(zero y0 + zero) Rest(zeroes)))
		y0       = Reduce(Sub taps)
		fir-taps = Zip-With(Mul taps fir)
		DF-II    = Reduce(Add fir-taps)
	}

	Resonator(freq bw) {
		Resonator = Cons( {
			w = #2 * freq * arg * Math:Pi
			r = Math:Exp(Neg(bw * arg))

			norm = (#1 - r * r)

			((norm #0 Neg(norm))
			 (#-2 * r * Math:Cos(w)  r * r))
		} )
	}
}