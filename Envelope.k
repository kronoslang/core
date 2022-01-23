Import Function
Import Algorithm
Import Math
Import IO

Package Envelope {
	Brief(documentation) {
		;; Make musical control envelopes out of trigger and gate signals.
		nil
	}

	BPF(gate segments...) {
		;; Breakpoint function envelope with linear `segments...` given as 
		;; a list of `(x y)` where `x` is an interval in seconds relative 
		;; to the start of the envelope. The envelope ticks at either
		;; the control rate or the signal rate of `gate`, whichever is higher.
		;;
		;; OUTPUT: (x y)
		;; interpolated coordinates along the bpf

		Use Algorithm

		(g _) = Reactive:Couple(gate Control:Signal(0))
		sr = Reactive:Rate(g)

		xs0 = Map(First segments...)
		xs1 = Map(First Rest(segments...))

		inc = Cache( 
				Concat(
					Zip-With((x1 x0) => #1 / (sr * (x1 - x0))  xs1 xs0)
					[0]))

		(x0 y0) = Select(segments... position)
		(x1 y1) = Select(segments... position + #1)
		rate = Select(inc position) & (g != 0)

		trigger = g > z-1(g)
		position = z-1(position + rate) & Not(trigger)

		h = Fraction(position)

		(Math:Linear-Interpolation(h x0 x1)
		 Math:Linear-Interpolation(h y0 y1))
	}

	Linear(gate segments...) {
		;; Envelope with linear `segments...`, given as a list of pairs
		;; in the format `(value seconds)`. The generator will produce
		;; linear segments sequentially towards the next `value` with the duration
		;; in `seconds`.
		;;
		;; In case the gate signal does not have a regular clock, it is upsampled
		;; to the control rate.

		Use Algorithm

		(g _) = Reactive:Couple(gate Control:Signal(0))
		sr = Reactive:Rate(g)

		segs = Map((v d) => (v #1 / Max(#1 d * sr)) segments...)

		(v0 rate) = Select(segs position)
		(v1 _)   = Select(segs position + #1)

		trigger = g > z-1(g)
		position = z-1(position + rate) & Not(trigger)

		Math:Linear-Interpolation(Fraction(position) v0 v1)
	}

	Slew(sig rate+ rate-) {
		;; Limits the slew of `sig`nal to at most `slew+` and at least `slew-`
		;; for each clock period of `sig`nal.

		prev = z-1(out)
		dist = sig - prev

		out = prev + Max(rate- Min(rate+ dist))

		out
	}

	Release(gate duration) {
		;; Slows down the release phase of the `gate` signal to ramp down
		;; over `duration` seconds.
		;;
		;; In case the gate signal does not have a regular clock, it is upsampled
		;; to the control rate.

		(g _) = Reactive:Couple(gate Control:Signal(0))
		sr = Reactive:Rate(g)
		rate = #1 / Max(#1 sr * duration)
		out = Max(0 Ternary-Select(g > #0 1 z-1(0 out - rate)))

		out
	}

	ADSR(gate attack decay sustain release) {
		;; Generates a linear attack-decay-sustain-release envelope
		;; given a `gate` signal. The envelope proceeds towards the
		;; sustain phase while the gate is up. When the gate is down,
		;; the ADS-phase ends and the signal tends towards `0` in
		;; `release` seconds. Upward edges in `gate` reset the
		;; envelope to the beginning of the attack phase.
		senv = Linear(gate [(0 attack) (1 decay) (sustain 1) (sustain 1)])
		renv = Release(gate release)
		senv * renv
	}

	AR(gate attack release) {
		;; Generates a linear attack-release envelope given a 'gate' signal.
		;; The upward edge in 'gate' becomes a ramp of 'attack' seconds,
		;; and the downard edge is a ramp of 'release' seconds.

		(g _) = Reactive:Couple(gate Control:Signal(0))

		sr = Reactive:Rate(g)
		ar = #1 / Max(#1 attack * sr)
		rr = #-1 / Max(#1 release * sr)

		Slew(g ar rr)
	}
}