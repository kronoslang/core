Import IO
Import Complex

Merge-Updates(sigs...) {
	Merge-Updates = Reactive:Merge(Reactive:Adjust-Priority(sigs... sigs... #0))
}

Recursive-Merge(sig transforms...) {
	state = Reactive:Resample(
				z-1(sig - sig 
						Merge-Updates(
							Algorithm:Map(t => t(state sig) transforms...)))
				sig)

	Recursive-Merge = state
}

Package Test {
	Signal-Injection() {
		reset = Control:Signal(-0.5)
		inc   = Reactive:Rate(reset) / Reactive:Rate(Audio:Signal(0))

		upd   = Audio:Signal(z-1(0 Reactive:Merge(upd + inc reset)))
		Signal-Injection = upd
	}

	Sine-Trigger() {
		freq  = Control:Param("freq" 440)
		coef  = Complex:Polar(freq * Math:Pi * #2 / Audio:Rate() 0.99999)

		reset = Reactive:Resample(Complex:Cons(0 1) freq)

		state = Audio:Signal(
					z-1(Complex:Cons(1 0) Reactive:Merge(
							Reactive:Adjust-Priority((state * coef reset) state #0))))

		Sine-Trigger = Complex:Real(state)
	}

	Sine-Trig2() {
		freq = Control:Param("freq" 440)
		dcy  = Control:Param("decay" 0.9999)

		reset = Reactive:Resample(Complex:Cons(0 1) freq dcy)
		coef  = Complex:Polar(freq * Math:Pi * #2 / Audio:Rate() dcy)
		Sine-Trig2  = Recursive-Merge( Audio:Signal(coef) Mul 'reset )
	}
}

