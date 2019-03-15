Import Approx
Import Closure
Import IO
Import Complex
Import "deprecated/Filter.k"
Import "deprecated/Interpolation.k"

Package Waveform {
	Sin(phase) { Sin = Approx:Cosine-Shape(Abs(phase - #0.5) #5) }
	Saw = phase => #-1 + #2 * phase
	Tri = phase => Abs(Saw(phase)) * #2 - #1
	Parabolic = phase => #2 * Saw(phase) * Saw(phase) - #1
	Pulse = width => (phase => Ternary-Select(phase < width Coerce(phase #1) Coerce(phase #-1)))
	Sqr = Pulse(#0.5)
}

Package Gen {
	With-Unit-Delay(func init) {
		;; Route the output of 'func' back to its argument through a unit delay. Initialize the delay to 'init'.
		st = z-1(init func(st))
		With-Unit-Delay = st
	}

	Phasor(clocking init inc) {
		;; Create a periodic ramp within [0,1], increasing by 'inc' every time 'clock' ticks
		wrap = x => x - Floor(x)
		Phasor = With-Unit-Delay(s => wrap(s + clocking(inc)) init)
	}

	Osc(shape freq) {
		inc = freq / Audio:Rate()
		Osc = shape(Phasor(Audio:Signal freq - freq inc))
	}

	LFO(shape freq) {
		inc = freq / Rate-of(Control:Signal(0))
		LFO = shape(Phasor(Control:Signal freq - freq inc))
	}

	ULFO(shape freq) {
		ULFO = #0.5 * (#1 + LFO(shape freq))
	}
}

Package Audio-File {
	Scrub(audio-file speed) {
		;; Plays the asset 'audio-file' with interpolation and variable 'speed'
		;; multiplier. Speed of 1 is normal playback.

		(sr waveform) = Audio:Loop(audio-file)
		counter = z-1(Audio:Signal(Audio:Signal(counter + Coerce(Double speed))))
		pos = counter * (sr / Reactive:Rate(counter))
		Interpolation:Hermite(Coerce(Float pos) waveform)
	}

	Play(audio-file) {
		;; Plays the asset 'audio-file'
		Scrub(audio-file 1)
	}

}

Package Noise {
	Pseudo-White(seed) {
		rng = Gen:With-Unit-Delay(x => Audio:Signal(x * 3.9999d * (1d - x)) seed)
		Pseudo-White = 2 * Coerce(Float rng - 0.5d)
	}
}

Package Wave {
	Brief(documentation) {
		;; Defines geometric waveform oscillators for audio.
		nil
	}

	Sin(freq) {
		;; Audio rate sinusoid generator suitable for frequency modulation.
		Sin = :Gen:Osc(:Waveform:Sin freq)
	}

	Sin-MCF(freq) {
		;; Audio rate sinusoid generator based on the Magic Circle formula. Very CPU-efficient, but the amplitude is unstable when frequency changes.
		T = Interval-of(Audio:Signal(0))
		e = Audio:Signal(#2 * Math:Sin(Math:Pi * freq * T))
		x2d = z-1(Coerce(freq #0) x2)
		x1 = z-1(Coerce(freq #1) x1) + e * x2d
		x2 = x2d - e * x1
		Sin-MCF = x1
	}

	Sin-DWG(freq) {
		;; Audio rate sinusoid generater based on a digital waveguide. It is very pure and CPU-efficient, but not for audio-rate modulation such as FM.
		R = #1
		b1 = #1
		theta = freq * Math:Pi * #2 / Audio:Rate()

		g = R * R
		t = Math:Tan(theta)
		cp = Math:Sqrt(g / (g + t * t * ((#1 + g) * (#1 + g) + (#1 - g) * (#1 - g)) / #4 ))

		x1 = z-1(Coerce(freq #1) Audio:Signal(x0))
		y1 = z-1(Coerce(freq #0) Audio:Signal(y0))

		tmp = cp * (x1 + y1)
		x0 = tmp - y1
		y0 = x1 + tmp

		Sin-DWG = x0
	}


	Saw(freq) {
		;; A Simplistic sawtooth generator without band limiting. Updates at the audio rate, oscillating at 'freq' Hz.
		Saw = :Gen:Osc(:Waveform:Saw freq)
	}

	Tri(freq) {
		Tri = :Gen:Osc(:Waveform:Tri freq)
	}

	DPW(freq) {
		;; Implements a differentiated parabolic wave algorithm to provide a better quality sawtooth oscillator for audio rates. Updates at the audio rate, oscillating at 'freq' Hz.
		sr = Audio:Rate()
		phasor = Saw(freq)
		c = sr / (#4 * freq)
		ig = phasor * phasor
		z = ig - ig
		d1 = z-1(ig ig)
		d2 = z-1(d1 d1)
		DPW = (ig - d2) * c
	}

	BLIT(freq phase-offset) {
		;; Provides a band-limited impulse train via the discrete summation formula. May produce clicks when the frequency is swept.
		sr = Audio:Rate()
		cps = freq / sr
		per = #1 / cps
		P2  = per / #2
		N = #1 + Floor(P2)
		NQ = #0.8
		a = Math:Pow(NQ, #1 / P2)
		aN = Math:Pow(a, N)

		phase = Gen:Phasor(Audio:Signal freq - freq cps) + phase-offset
		beta = #2 * Math:Pi * (phase - Floor(phase))
		Nbeta = N * beta

		cos = Math:Cos

		cosbeta = cos(beta)

		n = #1 - aN * cos(Nbeta) - a * (cosbeta - aN * cos(Nbeta - beta))
		d = per * (#1 + a * (-2 * cosbeta + a))

		BLIT = (n / d) - cps
	}

	Dual-BLIT(freq width coef) {
		blits = BLIT(freq #0) + BLIT(freq width) * coef
		Dual-BLIT = Filter:Integrate(blits 0.96)
	}

	PWM-Blit(freq width) {
		PWM-Blit = Dual-BLIT(freq width #-1)
	}
}