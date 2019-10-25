Import Math
Import Vector

Package Delay {

	Sample-Delay(sig num-samples) {
		;; Delays 'sig'nal for 'num-samples' ticks of its clock.
		;; 'num-samples' must be an invariant constant, such as #100.
		rbuf(Constraints:Constant!(num-samples) sig)
	}

	Comb(sig num-samples feedback) {
		;; Delays 'sig'nal by 'num-samples' ticks of its clock.
		;; 'num-samples' must be an invariant constant, such as #10.
		;; The delayed output is added back to the input signal,
		;; multiplied by 'feedback'

		out = rbuf(Constraints:Constant!(num-samples) 
				   sig + feedback * out)

		out
	}


	Sample-Delay(sig num-samples max-delay) #[Extend] {
		;; Delays 'sig'nal for 'num-samples' ticks of its clock.
		;; 'num-samples' is dynamic and can vary up to 'max-delay', which
		;; must be an invariant constant..
		(buf out pos) = rcsbuf(Constraints:Constant!(max-delay) sig)
		Select-Wrap(buf pos - num-samples)
	}

	Cons(sig max-delay) {
		;; Constructs a dynamic delay line in the form of a function that can
		;; be evaluated to retrieve a delayed 'sig'nal. Delay line memory 
		;; is allocated according to 'max-delay', which must be an invariant
		;; constant, such as #100, which corresponds to 100 ticks of the
		;; 'sig'nal clock. 
		;; 
		;; 'Eval'uate the (closure) output of this function with a parameter
		;; specifying the desired delay up to 'max-delay' frames of 'sig'nal.
		;; The output can be enhanced by wrapping it in interpolation, or 
		;; altering the time base, such as 'Compose((* sample-rate) Function:Wrap-Hermite(delay-fn))' 
		;; which would result in a 3rd order interpolated delay with the parameter in seconds.

		delay => Sample-Delay(sig delay max-delay) 
	}

	Static-Delay(sig delay-time buffer-size) {
		;; Delays 'sig'nal by 'delay-time' seconds, which can vary 
		;; up to 'buffer-size' ticks of 'sig'nal clock. The delayed signal
		;; is not interpolated, so this delay is best used with static 
		;; 'delay-time'.

		Sample-Delay(sig delay-time * Rate-of(sig) buffer-size)
	}

	Dynamic-Delay(sig delay-time buffer-size) {
		;; Delays 'sig'nal by 'delay-time' seconds, which can vary
		;; up to 'buffer-size' ticks of 'sig'nal clock. The delayed signal
		;; supports fractional delays with 3rd degree polynomial interpolation,
		;; making this delay suitable for modulating 'delay-time'.

		sr = Rate-of(sig)

		(buf out pos) = rcsbuf(Constraints:Constant!(buffer-size) sig)

		smp-pt = pos - delay-time

		points = Vector:Explode(Select-Wrap(buf Vector:Cons(-1i 0i 1i 2i) + smp-pt))

		Math:Hermite-Interpolation(Fraction(smp-pt) points)
	}

	Static-Delay(sig delay-time buffer-size feedback-fn) #[Extend] {
		;; Delays 'sig'nal by 'delay-time' seconds, which can vary 
		;; up to 'buffer-size' ticks of 'sig'nal clock. The delayed signal
		;; is not interpolated, so this delay is best used with static 
		;; 'delay-time'. Delayed output is added to the input signal
		;; processed via the 'feedback-fn', e.g. a damping filter
		;; or a feedback coefficient such as '(* 0.5)'.

		(buf out pos) = rcsbuf(sig - sig 
							   Constraints:Constant!(buffer-size)
							   sig + feedback-fn(fbout))

		num-samples = delay-time * Rate-of(sig)

		fbout = z-1(Select-Wrap(buf pos - num-samples + #1))

		fbout
	}

	Dynamic-Delay(sig delay-time buffer-size feedback-fn) #[Extend] {
		;; Delays 'sig'nal by 'delay-time' seconds, which can vary
		;; up to 'buffer-size' ticks of 'sig'nal clock. The delayed signal
		;; supports fractional delays with 3rd degree polynomial interpolation,
		;; making this delay suitable for modulating 'delay-time'. Delayed output is added to the input signal
		;; processed via the 'feedback-fn', e.g. a damping filter
		;; or a feedback coefficient such as '(* 0.5)'.

		sr = Rate-of(sig)

		(buf out pos) = rcsbuf(sig - sig
							   Constraints:Constant!(buffer-size)
							   sig + feedback-fn(fbout))

		smp-pt = pos - delay-time * Rate-of(sig)

		points = Vector:Explode(Select-Wrap(buf Vector:Indices(#4) + smp-pt))

		fbout = z-1(Math:Hermite-Interpolation(Fraction(smp-pt) points))

		fbout
	}
}