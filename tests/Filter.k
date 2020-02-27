
Import Algorithm
Import Closure
Import "Osc.k"
Import Gen
Import Filter
Import Complex
Import Vector

Package Biquad {
	Direct-II(x0 b0 b1 b2 a1 a2) {
		zero = x0 - x0

		y1 = z-1(zero y0)
		y2 = z-1(zero y1)
		y0 = x0 - y1 * a1 - y2 * a2
		Direct-II = b0 * y0 + b1 * y1 + b2 * y2
	}
}

Package Design {
	Resonator(amp freq bw sample-rate) {
		w = #2 * Math:Pi * freq / sample-rate
		r = Math:Exp(Neg(Math:Pi * bw / sample-rate))
		norm = (#1 - r * r) * amp

		b0 = norm
		b1 = #0
		b2 = Neg(norm)
		a1 = #-2 * r * Math:Cos(w)
		a2 = r * r

		Resonator = (b0 b1 b2 a1 a2)
	}
}

Package Test {
	Simple-Resonator() {
		mod-freq = 0.5
		mod-depth = 220
		freq = Control:Signal(220 + Taylor-Sin(mod-freq mod-depth))

		filter = sig => Biquad:Direct-II(sig
			Design:Resonator(#1 freq #10 Rate-of(sig)))

		source = Pseudo-White(0.5d)

		Simple-Resonator = filter(source)
	}

	Static-Resonator() {
		filter = (sig freq bw) =>
			Biquad:Direct-II(sig
				Design:Resonator(#1 freq bw Rate-of(sig)))

		noise = Pseudo-White(0.5d)

		Static-Resonator = filter(noise 440 4)
	}

	Resonator-Bank() {
		filter = (sig freq bw) =>
			Biquad:Direct-II(sig
				Design:Resonator(#1 freq bw Rate-of(sig)))

		noise = Pseudo-White(0.5d)

		bank = Algorithm:Zip-With(
			(freq bw) => filter(noise freq bw)
			[440 550 660 770]
			[4 5 6 7])

		Resonator-Bank = Algorithm:Reduce((+) bank)
	}

	Vector-Resonator-Bank() {

		filter = (sig freq bw) =>
			Biquad:Direct-II(sig
				Design:Resonator(#1 freq bw Vector:Broadcast(#4 Rate-of(sig))))

		sig = Pseudo-White(0.5d)

		bank = filter(
			Vector:Pack(sig sig sig sig)
			Vector:Pack(440 550 660 770)
			Vector:Pack(4 5 6 7)
			)

		Vector-Resonator-Bank = Algorithm:Reduce((+)
			Vector:Unpack(bank))
	}

	Vector-Big-Bank() {
		num-filters = #32

		filter = (sig freq bw sr) =>
			Biquad:Direct-II(sig Design:Resonator(#1 freq bw sr))

		sig = Pseudo-White(0.5d)

		lfo = Taylor-Sin(0.4 1)
		fundamental = Control:Signal(220 + (220 * lfo))
		spread = fundamental * Control:Signal(lfo)

		bank = filter(
			Vector:Broadcast(num-filters sig)
			Vector:Pack(
				Algorithm:Expand(num-filters (+ spread) fundamental))
			#5
			Vector:Broadcast(num-filters Rate-of(sig))
			)

		Vector-Big-Bank = Algorithm:Reduce((+)
			Vector:Unpack(bank)) / num-filters
	}

	Simple-Halfband() {
		sr = Rate-of(Gen:Signal(0))
		Filter:Halfband(Gen:Sin(sr * (0.5 + 0.5 * Gen:Sin(0.2)))) * Gen:Sin(sr / 4)
	}

	Simple-Tone() {
		Filter:Tone(Gen:Noise() Gen:Phasor(1))
	}

	Library-Resonator() {
		Filter:Resonator(Gen:Saw(44.1) 3000 * Gen:Phasor(1) Gen:Phasor(0.1) * 1500)
	}

	Pole-Formats() {
		Use Filter
		Use Gen 

		Pole-Zero(
			Complex:Real(
				Zero(
					Pole(Gen:Noise(0.499d)
						 Complex:Unitary(0.1))
					-1))
			Vector:Cons(-0.2 -0.1 0.1 0.2)
			#0.5) * #0.01
	}
}