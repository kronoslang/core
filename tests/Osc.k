Import Complex
Import IO
Import Approx

Complex-Sin(freq amp) {
	coef = Complex:Unitary(#2 * Math:Pi * freq / Rate-of(Audio:Clock))
	osc = z-1(Complex:Cons(1 0) osc * Audio:Signal(coef))
	Complex-Sin = Complex:Real(osc) * amp
}

Periodic-Ramp(freq) {
	inc = freq / Rate-of(Audio:Clock)
	next = z-1(freq - freq wrap + Audio:Signal(inc))
	wrap = next - Floor(next)
	Periodic-Ramp = wrap
}

Taylor-Sin(freq amp) {
	phasor = Periodic-Ramp(freq)
	Taylor-Sin = amp * Approx:Cosine-Shape(Abs(phasor - 0.5) #5)
}

Downsampled-Sin(freq amp) {
	inc = freq / Rate-of(Control:Signal-Fine(0))
	next = z-1(freq - freq wrap + Control:Signal-Fine(inc))
	wrap = next - Floor(next)
	ramp = wrap

	Downsampled-Sin = Audio:Signal(Approx:Cosine-Shape(Abs(ramp - 0.5) #5)) * amp
}

Iterative(step-function initializer) {
	state = step-function(z-1(initializer Audio:Signal(state)))
	Iterative = state
}

Pseudo-White(seed) {
	rng = Iterative(x => x * 3.9999d * (1d - x) seed)
	Pseudo-White = 2 * Coerce(Float rng - 0.5d)
}

Clicker(freq) {
	inc = freq / Rate-of(Audio:Clock)
	phasor = z-1(inc - inc wrap + inc)
	edge = (phasor >= #1) & #1
	wrap = phasor - edge
	Clicker = edge
}


Package Test {
	Sin() {
		Sin = Complex-Sin(440 1)
	}

	Waveshaping() {
		Waveshaping = Taylor-Sin(440 1)
	}

	FM() {
		lfo = Taylor-Sin(2 220)
		mod = Taylor-Sin(110 lfo)
		FM = Taylor-Sin(110 + mod 0.5)
	}

	Sin-Seq() {
		f = IO:Source("freq" 440 #0)
		a = IO:Source("amp" 1 #0)
		Sin-Seq = Complex-Sin(f a)
	}

	Mixed-Rate-Osc() {
		ramp = Periodic-Ramp(440)
		lfo = Approx:Cosine-Shape(Control:Signal(Abs(ramp - 0.5)) #5)
		Mixed-Rate-Osc = Taylor-Sin(440 + lfo 0.5)
	}

	Control-Rate-Sin() {
		lfo = Downsampled-Sin(0.5 440)
		Control-Rate-Sin = (Downsampled-Sin(440 + lfo 0.5) Taylor-Sin(440 + lfo 0.5))
	}

	Noise() {
		Noise = Pseudo-White(0.5d) * 0.3
	}

	Clicks() {
		freq = (5 + Taylor-Sin(0.05 4.8))
		Clicks = Clicker(freq)
	}

	Lofi-Seq() {
		Use Algorithm

		t = z-1(Audio:Signal(t + 1i))
		shifts = [0i 2i 7i 11i 9i]

		b8 = Reduce(Or Map(Curry(BitShiftRight t) shifts))
		(b8 & 0xff) / 256 - 0.5
	}
}

Package Sequence {
	Sin-Seq = [
		(0   "freq" 440)
		(0   "amp"  1)
		(0.2 "freq" 880)
		(0.4 "freq" 660)
		(0.4 "amp"  0.5)
		(0.6 "freq" 330)
		(0.6 "amp"  0.7)
		(1 	 "amp"  0)
		(1 	 "end"  nil)
	]
}