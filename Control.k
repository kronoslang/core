Import Algorithm
Import IO

Package Control {
	Brief() {
		;; Tools for control signals. Edge detectors, signal smoothers and hold circuits.
		nil
	}

	Sample-and-Hold(sig sample?) {
		;; When `sample?` is not true, freeze the value of `sig`nal.
		state = z-1(sig Algorithm:Choose(sample? sig state))
		state
	}

	Edge+(sig) {
		;; True when `sig` contains an upward edge
		sig > z-1(sig)
	}

	Edge-(sig) {
		;; True when `sig` contains a downward edge
		sig < z-1(sig)
	}

	Edge+-(sig) {
		;; True when the value of `sig` changes
		sig != z-1(sig)
	}

	Smooth(sig rate) {
		;; Resamples 'sig'nal to control rate and applies a lowpass filter
		;; to reduce variations faster than 'rate' in Hertz.

		in   = Control:Signal( Constraints:Scalar!(sig) )
		coef = Max(#0 Min(#1 rate * Interval-of(in)))
		prev = z-1(next)
		next = prev + coef * (in - prev)

		(s ss) = sig
		ty = Class-of(sig)

		Polymorphic( (Recur(s rate) Recur(ss rate))
					  Make(ty Recur(Break(ty sig) rate)) 
					  next
					  sig )
	}

	Smooth-Slower(sig rate) {
		;; Resamples 'sig'nal to a coarse control rate and applies a lowpass filter
		;; to reduce variations faster than 'rate' in Hertz.

		in   = Control:Signal-Coarse(Constraints:Scalar!(sig))
		coef = Max(#0 Min(#1 rate * Interval-of(in)))
		prev = z-1(next)
		next = prev + coef * (in - prev)

		(s ss) = sig
		ty = Class-of(sig)

		Polymorphic( (Recur(s rate) Recur(ss rate))
					  Make(ty Recur(Break(ty sig) rate)) 
					  next
					  sig )
	}

	Smooth-Faster(sig rate) {
		;; Resamples 'sig'nal to a finer control rate and applies a lowpass filter
		;; to reduce variations faster than 'rate' in Hertz.

		in   = Control:Signal-Fine(Constraints:Scalar!(sig))
		coef = Max(#0 Min(#1 rate * Interval-of(in)))
		prev = z-1(next)
		next = prev + coef * (in - prev)

		(s ss) = sig
		ty = Class-of(sig)

		Polymorphic( (Recur(s rate) Recur(ss rate))
					  Make(ty Recur(Break(ty sig) rate)) 
					  next
					  sig )
	}

	Smooth-Audio(sig rate) {
		;; Resamples 'sig'nal to audio rate and applies a lowpass filter
		;; to reduce variations faster than 'rate' in Hertz.

		in   = Audio:Signal(Constraints:Scalar!(sig))
		coef = Max(#0 Min(#1 rate * Interval-of(in)))
		prev = z-1(next)
		next = prev + coef * (in - prev)

		(s ss) = sig
		ty = Class-of(sig)

		Polymorphic( (Recur(s rate) Recur(ss rate))
					  Make(ty Recur(Break(ty sig) rate)) 
					  next
					  sig )
	}
}