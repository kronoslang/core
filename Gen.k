Import IO
Import Approx
Import Math
Import Filter

Package Gen {
	Brief(documentation) {
		;; Elementary signal generator system
		nil
	}

	Rate() {
		;; Outputs the 'sampling-rate' of the Generators
		Rate-of(Gen:Signal(0))
	}

	Interval() {
		;; Outputs the 'sampling-interval' of the Generators in seconds
		Interval-of(Gen:Signal(0))
	}

	Signal(sig) {
		;; Acts as a signal clock generator for all the generators. By default,
		;; 'sig' is resampled to the audio clock. You can use 'With-Binding' to
		;; override the signal clock. For example, `With-Binding(":Gen:Signal" Control:Signal { Gen:Sin(440) })`
		;; generates a control rate sinusoidal oscillator

		Audio:Signal(sig)
	}

	Cycles-per-Sample(freq) {
		;; Converts 'freq'uency in herts to Cycles-per-Sample according
		;; to the firing rate of 'Gen:Signal'. The output is also resampled
		;; according to 'Gen:Signal'.
		Signal(freq * (#1 / Rate-of(Signal(0))))
	}

	Phasor(freq) {
		;; Generates a periodic ramp signal in the range [0,1]. The period
		;; of the ramp is 'freq' Hz, sampled at the clock generated by
		;; 'Gen:Signal'.

		state = Fraction(z-1(state + Cycles-per-Sample(freq)))

		state
	}

	Package Shape {
		Saw(phase) {
			;; Converts a phasor output to a naive unipolar sawtooth wave with
			;; upward edges.
			#1 - phase
		}

		Saw-(phase) {
			;; Converts a phasor output to a naive unipolar sawtooth wave with
			;; downward edges
			phase
		}

		Triangle(phase) {
			;; Converts a phasor output to a naive unipolar triangular wave
			#2 * Abs(Fraction(phase + #0.5) - #0.5)
		}

		Pulse(width) {
			;; Makes a waveshaper for a naive rectangular pulse with
			;; width ranging from 0 to 1.
			Pulse = phase => Coerce(phase #1) & (phase < width)
		}
	}

	Osc(shape-fn freq) {
		;; Produces a signal by waveshaping the output of a
		;; phasor at 'frequency' by 'shape-fn', such as in
		;; Osc(440 Shape:Triangle). The wave-shaped output
		;; from the range [0,1] is rescaled to the bipolar
		;; range of [-1,1].
		shape-fn(Phasor(freq)) * #2 - #1
	}

	Osc(shape-fn freq maximum) #[Extend] {
		;; Produces a signal by waveshaping the output of a
		;; phasor at 'frequency' by 'shape-fn', such as in
		;; Osc(440 Shape:Triangle). The output is scaled to
		;; the unipolar range of [0, maximum]
		shape-fn(Phasor(freq)) * maximum
	}

	Osc(shape-fn freq minimum maximum) #[Extend] {
		;; Produces a signal by waveshaping the output of a
		;; phasor at 'frequency' by 'shape-fn', such as in
		;; Osc(440 Shape:Triangle). The output is scaled to
		;; the range of [minimum, maximum]
		range = maximum - minimum
		minimum + range * shape-fn(Phasor(freq))
	}

	Saw(freq) {
		;; Produces a bipolar naive sawtooth waveform
		;; with upward edges
		Osc(Shape:Saw freq)
	}

	Saw-(freq) {
		;; Produces a bipolar naive sawtooth waveform
		;; with downward edges
		Osc(Shape:Saw- freq)
	}

	Tri(freq) {
		;; Produces a bipolar naive triangular waveform
		Osc(Shape:Triangle freq)
	}

	Pulse(freq width) {
		;; Produces a bipolar naive pulse waveform with
		;; 'width' in the range of [0,1].
		Osc(Shape:Pulse(width) freq)
	}

	Saw(freq offset) #[Extend] {
		;; Produces a bipolar naive sawtooth waveform
		;; with upward edges and a phase offset of [0,1]
		;; in proportion to the waveform period.
		Osc(w => Shape:Saw(Fraction(w + offset)) freq)
	}

	Saw-(freq offset) #[Extend] {
		;; Produces a bipolar naive sawtooth waveform
		;; with downward edges and a phase offset of [0,1]
		;; in proportion to the waveform period.
		Osc(w => Shape:Saw-(Fraction(w + offset)) freq)
	}

	Tri(freq offset) #[Extend] {
		;; Produces a bipolar naive triangular waveform
		;; with a phase offset of [0,1] in proportion to
		;; the waveform period.
		Osc(w => Shape:Triangle(Fraction(w + offset)) freq)
	}

	Pulse(freq width offset) #[Extend] {
		;; Produces a bipolar naive pulse waveform with
		;; 'width' in the range of [0,1], with a phase offset of [0,1]
		;; in proportion to the waveform period.
		p = Shape:Pulse(width)
		Osc(w => p(Fraction(w + offset)) freq)
	}

	Sin(freq) {
		;; Produces a polynomial sinusoid waveform.
		Osc(w => Approx:Cosine-Shape(Abs(Fraction(w + #0.25) - #0.5) #5)
			freq #1)
	}

	Sin(freq offset) #[Extend] {
		;; Produces a polynomial sinusoid waveform with a phase 'offset'
		;; against a cosine wave, measured in periods of the waveform.
		Osc(w => Approx:Cosine-Shape(Abs(Fraction(w + #0.25 + offset) - #0.5) #5)
			freq #1)
	}

	Sin-Waveguide(freq) {
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

		Sin-Waveguide = x0
	}

	Slower(factor fn) {
		Recur(factor fn nil)
	}

	Slower(factor fn args...) #[Extend] {
		;; Function 'fn' is evaluated in a context where all the
		;; signal sources in the Gen package update at a rate
		;; that is slower by 'factor' in comparison to the current one.

		current-signal = Signal

		With-Binding(":Gen:Signal" {
			new-tick = Reactive:Downsample(current-signal(0) factor)
			Reactive:Resample(arg new-tick)
		} { fn(args...) })
	}

	Faster(factor fn) {
		Recur(factor fn nil)
	}

	Faster(factor fn args...) #[Extend] {
		;; Function 'fn' is evaluated in a context where all the
		;; signal sources in the Gen package update at a rate
		;; that is faster by 'factor' in comparison to the current one.

		current-signal = Signal

		With-Binding(":Gen:Signal" {
			new-tick = Reactive:Upsample(current-signal(0) factor)
			Reactive:Resample(arg new-tick)
		} { fn(args...) })
	}

	Noise(seed) {
		;; Generate a white noise sound from a seed value that should be
		;; close to but not exactly 0.5. 

		state = z-1(Coerce(Double Or(seed 0.499d)) 
					Signal(state * #3.9999 * (#1 - state)))
					
		2 * Coerce(Float state) - 1
	}

	Ramp(trig rate) {
		;; Produces a signal that starts from zero and changes linearly, at `rate` per second. When `trig` signal
		;; has an upward edge, the ramp is reset to zero.

		sr = Rate-of(Signal(0))
		inc = rate / sr
		state = (trig >= z-1(0 trig)) & z-1(0 state + inc)

		state
	}

	Oversample(num-stages fn args...) {
		;; Within function 'fn', double the rate of 'Gen:Signal' 'num-stages' times.
		;; Each stage output is equipped with a halfband filter and the signal rate
		;; is decimated by 2. As a result, any 'Gen:Signal' clock at the output will
		;; correspond to the normal rate.

		; gentle slope with -103dB stopband for
		; all but the final decimation stages
		a = [#0.03583278843106211
			 #0.2720401433964576
			 #0.5720571972357003
			 #0.827124761997324]

		b = [#0.1340901419430669
			 #0.4243248712718685
			 #0.7062921421386394
			 #0.9415030941737551]

		factor = Math:Pow(#2 num-stages)

		sig = Faster(factor fn args...)

		decimate = sig => Reactive:Downsample(Filter:Polyphase(sig a b) #2)

		When(num-stages > #0
			 Reactive:Downsample(
			 	Filter:Halfband-HQ(
			 		Algorithm:Iterate(num-stages - #1 decimate sig)
			 		) #2))
	}

	Random(seed) {
		;; Generate random deviation in range [0,1] at the audio rate.
		lcg(seed a c) {
			Coerce(Int32 
				Coerce(Int64 seed) * Coerce(Int64 a) 
				+ Coerce(Int64 c))
		}

		state = z-1(Coerce(Int32 seed) 
					Gen:Signal(lcg(state 1103515245i 12345i)))

		(state & 0x3fffffff) * Math:Pow(2 -30)
	}

	Random(seed deviation) #[Extend] {
		;; Generate random deviation in range [-deviation,deviation] at the audio rate.
		(Recur(seed) * #2 - #1) * deviation
	}

	Random(seed low-bound high-bound) #[Extend] {
		;; Generate random deviation in range [low-bound, high-bound] at the audio rate.
		(Recur(seed) * (high-bound - low-bound) + low-bound)
	}
}


;; backwards compatibility shims

:Wave:Sin = f => Gen:Sin(f #-0.25)
:Wave:Tri = Gen:Tri
:Wave:Saw = Gen:Saw-
:Wave:Sin-DWG = Gen:Sin-Waveguide
:Noise:Pseudo-White = Gen:Noise
:Gen:Drift = Gen:Random