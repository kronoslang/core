; the Algorithm library contains higher order
; functions like Expand, Map and Reduce

; the Complex library provides complex algebra

; the IO library provides parameter inputs

; the Closure library provides captures for
; lambdas

; the Math library provides the Pi constant

Import Algorithm
Import Complex
Import IO
Import Closure
Import Math
Import Implicit-Coerce

Generic-Oscillator(seed iterator-func) {
	; oscillator output is initially 'seed',
	; otherwise the output is computed by applying
	; the iterator function to the previous output

	; the audio clock rate is injected into the loop
	; with 'Audio:Signal'

	out = z-1(seed iterator-func(Audio:Signal(out)))

	Generic-Oscillator = out
}

Sinusoid-Oscillator(freq) {
	; compute a complex feedback coefficient
	norm = Math:Pi / Rate-of(Audio:Clock)
	feedback-coef = Complex:Unitary(freq * norm)

	; initially, the complex waveform starts from
	; phase 0
	initial = Complex:Unitary(0)

	; Haskell-style section; an incomplete binary operator
	; becomes an anonymous unary function, here closing over
	; the feedback coefficient
	state-evolution = (* feedback-coef)

	; the output of the oscillator is the real part of the
	; complex sinusoid
	Sinusoid-Oscillator = Complex:Real(
		Generic-Oscillator(initial state-evolution))
}

Main() {
	; receive user interface parameters
	f0 = Control:Param("f0" 10)
	fdelta = Control:Param("fdelta" 5)

	; number of oscillators; must be an invariant constant
	num-sines = #50

	; generate the frequency spread
	freqs = Algorithm:Expand(num-sines (+ (fdelta + f0)) f0)

	; apply oscillator algorithm to each frequency
	oscs = Algorithm:Map(Sinusoid-Oscillator freqs)

	; sum all the oscillators and normalize
	sig = Algorithm:Reduce((+) oscs) / num-sines

	Main = sig
}

Import Gen

Resonator(sig amp freq bw) {
    sample-rate = Reactive:Rate(sig)
    w = #2 * Math:Pi * freq / sample-rate
    r = Math:Exp(Neg(Math:Pi * bw / sample-rate))
    norm = (#1 - r * r) * amp
    a1 = #-2 * r * Math:Cos(w)
    a2 = r * r
	zero = sig - sig
    y1 = z-1(zero y0)
    y2 = z-1(zero y1)
    y0 = sig - y1 * a1 - y2 * a2
    Resonator = norm * (y0 - y2)
}

Phasor(freq) {
    driver = Audio:Signal(0) ; dummy driver
    sample-rate = Reactive:Rate(driver)
    state = z-1(freq - freq Audio:Signal(wrap))
    next  = state + freq * (#1 / sample-rate)
    wrap  = next - Floor(next)
    Phasor = state
}

Saw = freq => #2 * Phasor(freq) - #1
Tri = freq => #2 * Abs(Saw(freq)) - #1
Pulse = (freq width) => Ternary-Select(
	Phasor(freq) < width 1 -1)

Phasor2(clocking freq) {
    driver = clocking(0) ; dummy driver
    sample-rate = Reactive:Rate(driver)
    state = z-1(freq - freq clocking(wrap))
    next  = state + freq * (#1 / sample-rate)
    wrap  = next - Floor(next)
    Phasor2 = state
}

Saw2 = x => #2 * x - #1
Tri2 = x => #2 * Abs(Saw2(x)) - #1
Pulse2 = width => (x => Ternary-Select(x < width 1 -1))
Osc = (shape freq) => shape(Phasor2(Audio:Signal freq))
LFO = (shape freq) => #0.5 + #0.5 * shape(Phasor2(Control:Signal-Coarse freq))

Upsample-Linear(sig to-clock) {
	x0 = sig
    x1 = z-1(x0 - x0  x0)
    slow-rate = Reactive:Rate(sig)
    fast-rate = Reactive:Rate(to-clock(0))
    inc  = slow-rate / fast-rate
    wrap = x => x - Floor(x)
    state = z-1(0 to-clock(wrap(state + inc)))
    Upsample-Linear = x1 + state * (x0 - x1)
}

MyFilter(sig tone) {
    zero = sig - sig
    y1 = z-1(zero y0)
    y0 = y1 + tone * (sig - y1)
    MyFilter = y0
}

Type Multichannel
Package Multichannel {
	Cons(channels) {
        Cons = Make(:Multichannel channels)
	}

    As-Tuple(mc) #[Pattern] {
        As-Tuple = Break(:Multichannel mc)
	}

    Binary-Op(op a b) #[Pattern] {
        Binary-Op = Multichannel:Cons(
			Algorithm:Zip-With(op
			    Multichannel:As-Tuple(a)
			    Multichannel:As-Tuple(b)))
    }
}

Add(a b) #[Extend] {
    Add = Multichannel:Binary-Op(Add a b)
}

Sub(a b) #[Extend] {
    Sub = Multichannel:Binary-Op(Sub a b)
}

Mul(a b) #[Extend] {
    Mul = Multichannel:Binary-Op(Mul a b)
}


Multichannel?(mc) {
	Multichannel? = nil
	Multichannel? = Require(Multichannel:As-Tuple(mc) True)
}

Package Type-Conversion {
    Explicit(type data) #[Extend] {
		channels = Multichannel:As-Tuple(type)
		Explicit = When(Real?(data)
		    Multichannel:Cons(
		        Algorithm:Map('data channels)))
	}

	Implicit?(from to) #[Extend] {
		Implicit? = When(
			Real?(from) & Multichannel?(to) True)
	}
}

Parallel = (a b) => ( (c d) => (a(c) b(d)) )
Serial   = (a b) => ( x => (b(a(x))) )
Recursive(a b) {
	recursively = {
		(sig fn) = arg
		st = z-1(sig upd)
		upd = fn(st)
		upd
	}
	Recursive = in => recursively(in fb => a(b(fb) in))
}

Dup = '(_ _)
Infix-> = Serial
Infix~  = Recursive
Infix-< = (a b) => (a -> Dup -> b)
Infix|| = Parallel
;Fraction = x => x - Floor(x)

Convolution(sig coefs) {
	(c cs) = coefs
    z = sig - sig
    Convolution = When(Atom?(coefs) sig * coefs)
    Convolution = sig * c + Convolution(z-1(z sig) cs)
    Convolution = When(Nil?(coefs) 0)
}

Conv = coefs => ('Convolution(_ coefs))

Biquad = (a1 a2 b0 b1 b2) => ( ( Add ~ Conv(a1 a2) ) -> Conv(b0 b1 b2) )

Resonator2(freq bw) {
	w = #2 * Math:Pi * freq / Audio:Rate()
    r = Math:Exp(Neg(Math:Pi * bw / Audio:Rate()))
    norm = (#1 - r * r)
    Resonator2 = Biquad(#2 * r * Math:Cos(w)
                       Neg(r * r)
                       norm #0 Neg(norm))
}

Package Test {
	; These tests are trivial; they are to ensure that
	; the examples in my doctoral thesis do not ever
	; break.

	Supplementary-Example() {
		Supplementary-Example = Main()
	}

	Tutorial-01() {
		MyFunction = x => x + 10
		Tutorial-01 = Algorithm:Map(MyFunction 1 2 3 4 5)
	}

	MyFold(f tuple) {
		MyFold = tuple
		(x xs) = tuple
		MyFold = f(x MyFold(f xs))
	}

	Tutorial-02() {
		Tutorial-02 = MyFold(Add 1 2 3 4 5)
	}

	Tutorial-03() {
		Tutorial-03 = MyFold(String:Append "Hello" " " "World")
	}

	Tutorial-04() {
		add-sin = (freq sig) => sig + Wave:Sin(freq) * 0.1
		Tutorial-04 = MyFold(add-sin 440 550 660 0)
	}

	Tutorial-05() {
		oscs = Algorithm:Map(Wave:Sin 440 550 660)
		Tutorial-05 = MyFold(Add oscs) * 0.1
	}

	Tutorial-06() {
		Tutorial-06 = Algorithm:Expand(#10 (* 2) 1)
	}

	Tutorial-07() {
		f0 = 220
		ops = #3
		freqs = Algorithm:Expand(ops (+ 110) f0)
		rfreqs = Algorithm:Reduce((a b) => (b a) freqs)
		fm-op = (sig freq) => Wave:Sin(freq + sig * freq)
		Tutorial-07 = Algorithm:Reduce(fm-op 0 rfreqs)
	}

	Tutorial-08() {
		f0 = 220 + Wave:Sin(5.5) * 10
		ops = #3
		freqs = Algorithm:Expand(ops (+ 110) f0)
		rfreqs = Algorithm:Reduce((a b) => (b a) freqs)
		fm-op = (sig freq) => Wave:Sin(freq + sig * freq)
		Tutorial-08 = Algorithm:Reduce(fm-op 0 rfreqs)
	}

	Tutorial-09() {
		f0 = 220 + Wave:Sin(5.5) * 10
		ops = #4
		freqs = Algorithm:Expand(ops (+ 110) f0)
		rfreqs = Algorithm:Reduce((a b) => (b a) freqs)
		fm-op = (sig freq) => Wave:Sin(freq + sig * freq)
		Tutorial-09 = Algorithm:Reduce(fm-op 0 rfreqs)
	}

	Tutorial-10() {
		rfreqs = (0.1 330 440 550 165)
		fm-op = (sig freq) => Wave:Sin(freq + sig * freq)
		Tutorial-10 = Algorithm:Reduce(fm-op 0 rfreqs)
	}

	Tutorial-11() {
		Tutorial-11 = Phasor(440)
	}

	Tutorial-12() {
		Tutorial-12 = Phasor(440 + 110 * Phasor(1))
	}

	Tutorial-13() {
		Tutorial-13 = Algorithm:Reduce(
			(sig f) => Phasor(f + sig * f)
			0 1 110 440)
	}

	Tutorial-14() {
		Tutorial-14 = Pulse(55 0.5 + 0.5 * Tri(1))
	}

	Tutorial-15() {
		Tutorial-15 = Osc(Saw2 440)
	}

	Tutorial-16() {
		Tutorial-16 = Osc(Saw2 440 + 40 * LFO(Tri2 5))
	}

	Tutorial-17() {
		Tutorial-17 = Osc(Pulse2(LFO(Saw2 1)) 110)
	}

	Tutorial-18() {
		Tutorial-18 = Osc(Pulse2(0.5) 440) * LFO(Tri2 1)
	}

	Tutorial-19() {
		gain = Upsample-Linear(LFO(Tri2 1) Audio:Signal)
		Tutorial-19 = Osc(Pulse2(0.5) 440) * gain
	}

	Tutorial-20() {
		noise = Noise:Pseudo-White(0.499d)
		mod = 0.5 + 0.5 * Wave:Sin(1)
		Tutorial-20 = MyFilter(noise mod)
	}

	Tutorial-21() {
		Tutorial-21 = Multichannel:Cons(1 2 3) + Multichannel:Cons(20 30 40)
	}

	Tutorial-22() {
		noise = Noise:Pseudo-White(0.499d)
		stereo-noise = Multichannel:Cons(noise noise)
		lfo = freq => 0.5 + 0.5 * Wave:Sin(freq)
		mod = Multichannel:Cons(lfo(1) lfo(1.1))
		Tutorial-22 = MyFilter(stereo-noise mod)
	}

	Tutorial-23() {
		Tutorial-23 = (
			Coerce(Multichannel:Cons(0 0) 1)
			Coerce(Multichannel:Cons(0 0 0 0) 5d)
			)
	}

	Tutorial-24() {
		Tutorial-24 = (
			Multichannel:Cons(1 2) * 3
			5 + 7 * Multichannel:Cons(1 10)
			)
	}

	Tutorial-25() {
		pan = (sig p) => Multichannel:Cons(sig * (1 - p) sig * p)
		noise = Noise:Pseudo-White(0.499d)
		lfo = freq => 0.5 + 0.5 * Wave:Sin(freq)
		Tutorial-25 = pan(noise lfo(1))
	}

	Tutorial-26() {
		pan = (sig p) => Multichannel:Cons(sig * (1 - p) sig * p)
		noise = Noise:Pseudo-White(0.499d)
		lfo = freq => 0.5 + 0.5 * Wave:Sin(freq)
		Tutorial-26 = MyFilter(pan(noise lfo(1)) lfo(0.5))
	}

	Tutorial-27() {
		Tutorial-27 = (
			Eval(Parallel(Add Sub) (10 1) (2 20))
			Eval(Serial((+ 10) (* 5)) 1)
			)
	}

	Tutorial-28() {
		Phasor =
			Serial((/ Audio:Rate())
				Serial(Audio:Signal
					Recursive(Add Serial(
						Serial('(_ _)
							Parallel('_ Floor)) Sub))))
		Tutorial-28 = Phasor(220)
	}

	Tutorial-29() {
		Phasor = (/ Audio:Rate()) -> Audio:Signal
			-> (Add ~ ('_ -< ('_ || Floor) -> Sub))
		Tutorial-29 = Phasor(220)
	}

	Tutorial-30() {
		Phasor = (/ Audio:Rate()) -> Audio:Signal
			-> (Add ~ ('_ -< ('_ || Floor) -> Sub))
		Tri = Phasor -> (- 0.5) -> Abs -> (* 2) -> (- 0.5)
		Tutorial-30 = Tri(220)
	}

	Tutorial-31() {
		Phasor = (/ Audio:Rate()) -> Audio:Signal -> (Add ~ Fraction)
		Tutorial-31 = Phasor(220)
	}

	Tutorial-32() {
		SinOsc = (* (Math:Pi / Audio:Rate())) -> Complex:Unitary
			-> Audio:Signal -> (Mul ~ '_) -> Complex:Real
		Tutorial-32 = SinOsc(440)
	}

	Tutorial-33() {
		noise = 'Noise:Pseudo-White(0.499d)
		Tutorial-33 = Eval( noise -> Resonator2(440 10) nil )
	}
}