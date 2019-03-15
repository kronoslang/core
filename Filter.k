Import Algorithm
Import Complex
Import IO

Type Filter
Package Filter {
	Integrate(sig leak) {
		y1 = z-1(y1 * leak + sig)
		Integrate = y1
	}

	Allpass(sig coef) {
		y0 = x2 + ((sig - y2) * coef)
		x1 = z-1(sig)
		x2 = z-1(x1)
		y1 = z-1(y0)
		y2 = z-1(y1)

		y0
	}

	Convolve(sig coefs) {
		;; Convolves 'sig'nal with a FIR filter consisting of coefficients in 'coefs'. The length of the list determines the order of the filter. The coefficients are arranged from low to high order.
		Convolve = Algorithm:Fold(
			(c cs) => sig * c + z-1(cs * #0 cs)
			coefs)
	}

	Biquad(sig a0 a1 a2 b1 b2) {
		;; Two-pole, two-zero filter with forward coefficients
		;; 'a0' 'a1' and 'a1', and feedback coefficients
		;; 'b1' and 'b2'. The output comes from the difference
		;; equation y[t] = a0 x[t] + a1 x[t-1] + a2 x[t-2] - b1 y[t-1] - b2 y[t-2]
		x1 = z-1(sig)
		x2 = z-1(x1)
		y1 = z-1(y0)
		y2 = z-1(y1)
		y0 = sig * a0 + x1 * a1 + x2 * a2 - b1 * y1 - b2 * y2

		Biquad = y0
	}

	Resonator(sig freq bw) {
		;; Filters 'sig'nal to produce a resonant peak at 'freq'uency,
		;; with a bandwidth of 'bw' in Hertz.
		sr = Reactive:Rate-of(sig)
		w = #2 * freq * sr * Math:Pi
		r = Math:Exp(Neg(bw * sr))

		norm = (#1 - r * r)

		Biquad(sig
			norm #0 Neg(norm)
			#-2 * r * Math:Cos(w)  r * r)
	}

	Tone(sig cutoff) {
		;; Filter 'sig'nal with a simple one-pole 6dB/octave lowpass
		;; slope. The cutoff range is [0,1].
		y0 = y1 + cutoff * (sig - y1)
		y1 = z-1(y0)

		Tone = y0
	}

	Halfband(sig) {
		;; Filters 'sig'nal to remove the upper half of the signal band with a sharp
		;; transition. Uses less computation power than 'Halfband-HQ'.
		Use Algorithm[Reduce]

		a = [0.03583278843106211
			 0.2720401433964576
			 0.5720571972357003
			 0.827124761997324]

		b = [0.1340901419430669
			 0.4243248712718685
			 0.7062921421386394
			 0.9415030941737551]

		out-b = Reduce(Allpass sig b)

		(Reduce(Allpass sig a) + z-1(out-b)) * 0.5
	}

	Halfband-HQ(sig) {
		;; Filters 'sig'nal to remove the upper half of the signal band with a sharp
		;; transition. Provides more ideal filter characteristics than 'Halfband'.
		Use Algorithm[Reduce]

		a = [0.036681502163648017
			 0.2746317593794541
			 0.56109896978791948
			 0.769741833862266
			 0.8922608180038789
			 0.962094548378084]

		b = [0.13654762463195771
			 0.42313861743656667
			 0.6775400499741616
			 0.839889624849638
			 0.9315419599631839
			 0.9878163707328971]


		0.5 * (Reduce(Allpass sig a) + z-1(Reduce(Allpass sig b)))
	}
}