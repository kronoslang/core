; ---------------------------------------------------------------------------
;  Example 1 : Filter
; ---------------------------------------------------------------------------

Filter(x0 pole) {
	y1 = z-1( (pole - pole) y0 )
	; y1 is initially zero, subsequently delayed y0
	; the initial value of zero is expressed as 'pole - pole' to ensure
	; that the feedback path type matches the pole type

	y0 = x0 - pole * y1
	; compute y0, the output
	
	Filter = y0
	; this is the Filter output
}

; Straightforward single precision one pole filter 
; example1 = Filter(sig 0.5)

; Upgrade the signal path to double precision 
; example2 = Filter(sig 0.5d)

; Use as a resonator via a complex pole and reduction to real part
Resonator(sig w radius) {
	Resonator = Complex:Real(Filter(sig Complex:Polar(w radius)))
}
; ---------------------------------------------------------------------------
;  Example 2 : Generic Recursion
; ---------------------------------------------------------------------------

; routes a function output back to its first argument through a unit delay
Recursive(sig binary-func) {
	state = binary-func(z-1(sig - sig state) sig)
	Recursive = state
}

Filter2(sig pole) {
	; onepole filter is a recursive composition of a simple multiply-add expression
	dif-eq = (y1 x0) => x0 - pole * y1
	Filter2 = Recursive( sig dif-eq )
}

Buzzer(freq) {
	; local function to wrap the phasor
	wrap = x => x - Floor(x)
	; compose a buzzer from a recursively composed increment-wrap
	Buzzer = Recursive( freq (state freq) => 
		wrap(state + Frequency-Coefficient(Audio:Signal(0) freq)) )
}

Main() {
	; example usage
	Main = Filter2(Buzzer(440) 0.5)
}

; ---------------------------------------------------------------------------
;  Example 3 : Algorithmic Routing
; ---------------------------------------------------------------------------

; serial routing is a functional Fold
Fold(func data) {
	; extract two elements and the tail from the list
	(x1 x2 xs) = data

	; if tail is empty, result is 'func(x1 x2)'
	; otherwise, fold 'x1' and 'x2' into a new list head and recur
	Fold = Nil?(xs) : func(x1 x2)
		   Fold(func func(x1 x2) xs)
}

; parallel routing is a functional map
Map(func data) {
	; for an empty list, return an empty list
	Map = When(Nil?(data) data)

	; split the list to head and tail
	(x xs) = data

	; apply mapping function to head and recur
	Map = (func(x) Map(func xs))
}

; simple comb filter
Comb(sig feedback delay) {
	out = rbuf(sig - sig  delay sig + feedback * out)
	Comb = out
}

; allpass comb filter
Allpass-Comb(sig feedback delay) {
	vd = rbuf(sig - sig delay v)
	v = sig - feedback * vd
	Allpass-Comb = feedback * v + vd
}

Reverb(sig rt60) {
	; list of comb filter delay times for 44.1kHz
	delays = [ #1687 #1601 #2053 #2251 ]

	; compute rt60 in samples
	rt60smp = Rate-of( sig ) * rt60

	; a comb filter with feedback coefficient derived from delay time
	rvcomb = delay => Comb(sig Math:Pow( 0.001  delay / rt60smp ) delay)

	; comb filter bank and sum from the list of delay times
	combs-sum = Fold( (+) Map( rvcomb delays ) ) 

	; cascaded allpass filters as a fold 
	Reverb = Fold( Allpass-Comb [combs-sum (0.7 #347) (0.7 #113) (0.7 #41)] )
}


; ---------------------------------------------------------------------------
;  Example 4 : Sinusoid oscillator
; ---------------------------------------------------------------------------

Horner-Scheme(x coefficients) {
	Horner-Scheme = Fold((a b) => a + x * b coefficients)
}

Pi = #3.14159265359

Cosine-Coefs(order) {
	; generate next exp(x) coefficient from the previous one
	exp-iter = (index num denom) => (
		index + #1      	; next coefficient index
		num * #2 * Pi    	; next numerator 
		denom * index)  	; next denominator 

	flip-sign = (index num denom) => (index Neg(num) denom)

	; generate next cos(pi w) coefficient from the previous one
	sine-iter = x => flip-sign(exp-iter(exp-iter(x)))

	; generate 'order' coefficients
	Cosine-Coefs = Algorithm:Map(
			(index num denom) => (num / denom)
			Algorithm:Expand(order sine-iter (#2 #-2 * Pi #1)))
}

Cosine-Shape(x order) {
	x1 = x - #0.25
	Cosine-Shape = x1 * Horner-Scheme(x1 * x1 Cosine-Coefs(order))
}

; ---------------------------------------------------------------------------
;  Example 5 : Polyphonic synth
; ---------------------------------------------------------------------------

Import Algorithm
Import IO
Import Approx


; --- Voice Allocator ---------------------------------------------------------------
Package Polyphonic {
	Prioritize-Held-Notes(midi-bytes voices) {
		choose = Algorithm:Choose
		(status note-number velocity) = midi-bytes

		; kill note-number if event is note off or note on with 0 velocity
		kill-key = choose(status == 0x80 | (status == 0x90 & velocity == 0i)
						  note-number -1i)
		; new note-number if event is note on and non-zero velocity
		is-note-on = (status == 0x90 & velocity > 0i) 
		; a constant specifying highest possible priority value
		max-priority = 2147483647i
		; lower gate and reduce priority for released voice
		with-noteoff = Map((p k v) => (p - (max-priority & (k == kill-key))
						 	k  
						 	v & (k != kill-key))
							voices)
		; find oldest voice by selecting lowest priority
		lowest-priority = Fold(Min Map(First voices))
		; insert new note 
		Prioritize-Held-Notes = 
			Map((p k v) => choose((p == lowest-priority) & is-note-on  
								  (max-priority note-number velocity) 
								  (p - 1i k v)) 
				with-noteoff) 
	}

	Allocator(num-voices allocator midi-bytes) {
			; create initial voice allocation with running priorities so that the allocator
			; always sees exactly one voice as the oldest voice
			voice-init = Algorithm:Expand(num-voices (p _ _) => (p - 1i 0i 0i) (0i 0i 0i))

			; generate and clock the voice allocator loop from the MIDI stream
			old-voices = z-1(voice-init Reactive:Resample(new-voices midi-bytes))

			; perform voice allocation whenever the MIDI stream ticks
			new-voices = allocator(midi-bytes old-voices)
			Allocator = new-voices
	}
}

; --- Synthesizer -------------------------------------------------------------------
FM-Op(freq amp) {
	; apply sinusoid waveshaping to a sawtooth buzzer
	FM-Op = amp * Approx:Cosine-Shape(Abs(Buzzer(freq) - 0.5) #5)
}

FM-Voice(freq gate) {
	; attack and decay slew per sample
	(slew+ slew-) = (0.003 -0.0001)
	; upsample gate to audio rate
	gate-sig = Audio:Signal(gate)
	; slew limiter as a recursive composition over clipping the value differential
	env = Recursive( gate-sig (old new) => old + Max(slew- Min(slew+ new - old)) )
	; FM modulator osc
	mod = FM-Op(freq freq * 8 * env)
	; FM carrier osc
	FM-Voice = FM-Op(freq + mod env)
}

; --- Test bench --------------------------------------------------------------------
Synth(midi-bytes polyphony krate) {
	; transform MIDI stream into a bank of voices 
	voices = Polyphonic:Allocator( polyphony 
		Polyphonic:Prioritize-Held-Notes
		midi-bytes )

	lfo = Reactive:Downsample(FM-Op(5.5 1) krate)
	
	; make a simple synth from the voice vector
	Synth = Fold((+) 
			  Map((age key gate) => FM-Voice(
			  	440 * Math:Pow(2 (key - 69 +  lfo * gate / 256) / 12) ; freq
			  	gate / 128) ; amp
			  voices))
}


; --- Entry points ------------------------------------------------------------------
Import "Osc.k"

ramp = Buzzer(0.5)

Package Test {
	Filter-Lowpass() {
		noise = Pseudo-White(0.5d)
		Filter-Lowpass = Filter(noise -0.9 + Taylor-Sin(1 0.1)) * 0.1
	}

	Filter-Lowpass-Double() {
		noise = Pseudo-White(0.5d) 
		sig = Filter(noise -0.9d + Taylor-Sin(1d 0.1d)) * 0.1d
		Filter-Lowpass-Double = Coerce(Float Type-Check(sig Double-Precision?))
	}

	Filter-Complex() {
		noise = Pseudo-White(0.5d) * 0.01
		w = Taylor-Sin(1 0.03) + 0.05
		Filter-Complex = Resonator(noise w -0.995)
	}

	Naive-Saw() {
		simple-saw = { (Buzzer( arg ) - 0.5) * 0.2 }
		Naive-Saw = simple-saw(440) + simple-saw(550) + simple-saw(660)
	}

	Schroeder-Reverb() {
		mod = Math:Tanh( Taylor-Sin(0.5 10) ) + Taylor-Sin(5.5 0.05)
		simple-saw  = { (Buzzer( arg ) - 0.5) * 0.1 }
		sig = simple-saw(440 + 110 * mod) 
		Schroeder-Reverb = sig + Reverb(sig 5) * 0.2
	}

	Voice-Allocator() {
		; create external input for MIDI and mask off bytes from a 24-bit word
		midi = IO:Source("MIDI" 0i #1)
		status = BitShiftRight(midi 16i) & 0xf0 ; ignore channel nibble
		a = BitShiftRight(midi 8i) & 0xff       
		b = midi & 0xff
		Voice-Allocator = Synth((status a b) #3 #16)
	}

	Live-Synth() {
		Use MIDI
		midi = Input()
		Live-Synth = Synth((Status(midi) A(midi) B(midi)) #8 #16)
	}
}

Package Sequence {
	; test sequence
	Midi = [
		(0.5 "MIDI" 9453632i)
		(1   "MIDI" 9454656i)
		(1.5 "MIDI" 9455424i)
		(2.0 "MIDI" 8406016i)
		(2.5 "MIDI" 9456192i)
		(3.5 "MIDI" 8404992i)
		(3.5 "MIDI" 8406784i)
		(3.5 "MIDI" 8407552i)
		(4.0 "MIDI" 0i)
	]	
}








;-------------- Biquad
Biquad(sig b0 b1 b2 a1 a2) {
	zero = sig - sig
	
	; feedback section
	y0 = sig - y1 * a1 - y2 * a2
	y1 = z-1(zero y0)
	y2 = z-1(zero y1)

	; feedforward section
	Biquad = y0 * b0 + y1 * b1 + y2 * b2
}






;----- FFT
Stride-2(Xs) {
	Stride-2 = []
	Stride-2 = When(Nil?(Rest(Xs)) [First(Xs)])
	(x1 x2 xs) = Xs
	Stride-2 = (x1 Recur(xs))
}

Cooley-Tukey(dir Xs) {
	Use Algorithm		
	N    =    Arity(Xs)
	sub  = 'Cooley-Tukey(dir _)
	even = sub(Stride-2(Xs))
	odd  = sub(Stride-2(Rest(Xs)))

	twiddle-factor = Complex:Polar((dir * Math:Pi / N) * #2 #1) * 1
	twiddle = Zip-With(Mul odd Expand(N / #2 (* twiddle-factor) Complex:Cons(1 0)))

	(x1 x2 _) = Xs
	Cooley-Tukey = 
		N  < #1 : Raise("Cooley-Tukey FFT requires a power-of-two array input")
		N == #1 : [First(Xs)]
		N == #2 : [x1 + x2 x1 - x2]
			Concat(
				Zip-With(Add even twiddle)
				Zip-With(Sub even twiddle))				
}

Analyzer(sig N overlap) {
	(buf i out) = rcsbuf(0 N sig)
	frame = Reactive:Downsample(buf N / overlap)
	Analyzer = Cooley-Tukey(#1 frame)
}
