Import Algorithm
Import Complex
Import IO

Type Filter
Package Filter {
	Brief(documentation) {
		;; Audio filters to shape the frequency response
		nil
	}

	Integrate(sig feedback) {
		;; Integrate incoming 'sig'nal. For lossless integration, use 'feedback' of 1. Smaller
		;; feedback coefficients will produce a leaky integrator.
		y1 = z-1(y1 * feedback + sig)
		Integrate = y1
	}

	Allpass(sig coef) {
		;; A second-order allpass filter
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
			(c cs) => sig * c + z-1(cs)
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

	Lowpass(sig cutoff resonance) {
		;; Resonant lowpass filter. Attenuate frequencies above 'cutoff'.
		;; From https://www.musicdsp.org/en/latest/Filters/38-lp-and-hp-filter.html
		si = Interval-of(sig)

		c = #1 / Math:Tan(Math:Pi * 
					Max(0.0001 Min(0.4999 cutoff * Interval-of(sig))))

		r = Max(#0.1 Math:Sqrt(#2) * Min(#1 #1 - resonance))

		a = #1 / (#1 + r * c + c * c)
		b1 = #2 * (#1 - c * c) * a
		b2 = (#1 - r * c + c * c) * a

		Biquad(sig a a + a a b1 b2)
	}

	Highpass(sig cutoff resonance) {
		;; Resonant highpass filter. Attenuate frequencies below 'cutoff'.
		;; From https://www.musicdsp.org/en/latest/Filters/38-lp-and-hp-filter.html

		si = Interval-of(sig)
		
		c = Math:Tan(Math:Pi * 
				Max(0.0001 Min(0.4999 cutoff * Interval-of(sig))))
					
		r = Max(#0.1 Math:Sqrt(#2) * Min(#1 #1 - resonance))

		a0 = #1 / (#1 + r * c + c * c)
		a1 = #-2 * a0
		b1 = #2 * (c * c - #1) * a0
		b2 = (#1 - r * c + c * c) * a0

		Biquad(sig a0 a1 a0 b1 b2)
	}

	Resonator(sig freq bw) {
		;; Filters 'sig'nal to produce a resonant peak at 'freq'uency,
		;; with a bandwidth of 'bw' in Hertz.
		
		sr = Interval-of(sig)
		w = #2 * freq * sr * Math:Pi
		r = Math:Exp(Neg(bw * sr))

		norm = (#1 - r * r)

		Biquad(sig
			norm #0 Neg(norm)
			#-2 * r * Math:Cos(w)  r * r)
	}

	Tone(sig cutoff) {
		;; Filter 'sig'nal with a simple one-pole 6dB/octave lowpass
		;; slope. The cutoff range is [0,1] for closed or fully open.
		y0 = y1 + cutoff * (sig - y1)
		y1 = z-1(y0)

		Tone = y0
	}

	Lpf6(sig cutoff) {
		;; Filter 'sig'nal with a simple one-pole 6dB/octave lowpass
		;; slope. The cutoff is specified in Hertz.

		Tone(sig Max(0 Min(0.49999 cutoff * Interval-of(sig))))
	}

	Pole(sig pole) {
		;; First-order filter with a single `pole`
		y0 = sig + z-1(y0) * pole

		y0
	}

	Zero(sig zero) {
		;; First-order filter with a single `zero`

		sig - zero * z-1(sig)

	}

	Pole-Zero(sig pole zero) {
		;; First-order filter with one `pole` and one `zero`.

		y0 = sig + y1 * pole
		y1 = z-1(y0)
		
		y0 - zero * y1
	}

	DC(sig) {
		;; Remove any DC offset from 'sig'nal
		R = #1 - (#190 / Rate-of(sig))
		out = sig - z-1(sig) + R * z-1(out)

		out
	}

	Polyphase(sig a b) {
		;; Send 'sig'nal through two allpass filter cascades with coefficient lists
		;; given by 'a' and 'b'.
		Use Algorithm[Reduce]
		#0.5 * (Reduce(Allpass sig a) + z-1(Reduce(Allpass sig b)))
	}

	Halfband(sig) {
		a = [#0.03583278843106211
			 #0.2720401433964576
			 #0.5720571972357003
			 #0.827124761997324]

		b = [#0.1340901419430669
			 #0.4243248712718685
			 #0.7062921421386394
			 #0.9415030941737551]

		Polyphase(sig a b)
	}

	Halfband-HQ(sig) {
		a = [#0.036681502163648017
			 #0.2746317593794541
			 #0.56109896978791948
			 #0.769741833862266
			 #0.8922608180038789
			 #0.962094548378084]

		b = [#0.13654762463195771
			 #0.42313861743656667
			 #0.6775400499741616
			 #0.839889624849638
			 #0.9315419599631839
			 #0.9878163707328971]

		Polyphase(sig a b)
	}

	Upsample(sig) {
		;; Double-samples 'sig' by inserting zeroes and halfband-filtering. 
		;; Please note that the output will tick at twice the rate of 'sig'.

		chopper = Reactive:Resample(1 - z-1(chopper) Reactive:Upsample(sig #2))

		Halfband(sig * chopper)

	}

	Downsample(sig) {
		;; Half-band filter 'sig' and drop every other sample. Please note
		;; that the output will tick at half the rate of 'sig'.

		Reactive:Downsample(Halfband(sig) #2)
	}

	SVF(sig cutoff resonance) {
		;; Double-sampled stable state-variable filter. Filter operates at the 'cutoff' frequency and 'resonance' is in range [0,1].
		;; from https://www.musicdsp.org/en/latest/Filters/92-state-variable-filter-double-sampled-stable.html.
		;;
		;; OUTPUTS: (notch lowpass highpass bandpass peaking)

		fi = Interval-of(sig)
		res = Max(0 Min(1 resonance))

		w = #2 * Math:Sin(Math:Pi * Min(#0.25, #0.5 * cutoff * fi))
		damp = Min(#2 * (#1 - Math:Pow(res #0.25)) 
				   Min(#2 #2 / w - w * #0.5))

		Step(in low* band*) {
			notch = in - damp * band*
			low   = low* + w * band*
			high  = notch - low
			band  = w * high + band*

			Step = (notch low high band)
		}

		(n l h b) =             Step(sig z-1(low) z-1(band))
		(notch low high band) = Step(sig l b)

		SVF = (notch low high band low - high)
	}

}