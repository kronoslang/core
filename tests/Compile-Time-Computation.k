Import Algorithm


Fact(n) {
	When(n > #1
			n * Fact(n - #1)
		 Otherwise
		 	#1)
}


is = Algorithm:Expand(#10 (+ #1) #0)


Algorithm:Map(Fact is)


Sin-Coef(n) {
	Math:Pow(#-1 n) / Fact(#2 * n + #1)
}


coefs = Algorithm:Map(Sin-Coef is)

coefs

Horner(x coefs...) {
	Algorithm:Fold((c p) => c + x * p coefs...)
}


SinA(w) {
	w * Horner(w * w coefs)
}


Import Math


Algorithm:Map(SinA
			  Math:Pi / 4
			  Math:Pi / 3
			  Math:Pi / 2)

CosA(w) {
	SinA(Abs(w) - Math:Pi / #2)
}


Algorithm:Map(CosA
			  Math:Pi
			  Math:Pi / -2
			  0
			  Math:Pi / 2
			  Math:Pi )


Import Gen


SinOsc(freq) {
	; Refer to Map, Expand and Fold from Algorithm
	; with implicit package prefix
	Use Algorithm[Map Expand Fold]

	N = #10 ; approximation order

	; compute polynomial coefficients
	coefs = Map(Sin-Coef Expand(N (+ #1) #0))

	; phasor
	phase = Gen:Phasor(freq)

	; map phasor to [-Pi, Pi]
	x = ( Abs(phase * 2 - 1) - 0.5 ) * Math:Pi

	x * Horner(x * x coefs)
}


; Frequency Modulation Synthesis


f0 = 110

mod = SinOsc(0.1) * 32

op1 = SinOsc(f0 * 3)

op2 = SinOsc((1 + op1 * mod) * f0)



:Test:Audio-Zas17() { snd = CosA((Gen:Phasor(440) * 2 - 1) * Math:Pi) * 0.2 snd }

:Test:Audio-3iB1O() { snd = SinOsc(440 + 10 * SinOsc(5.5)) * 0.2 snd }

:Test:Audio-C4IPs() { snd = op2 * 0.2 snd }

:Test:Eval-aR7hc() { Handle(Algorithm:Map(Fact is) '_ ) }

:Test:Eval-pn3K+() { Handle(coefs '_ ) }

:Test:Eval-y0DWh() { Handle(Algorithm:Map(SinA
			  Math:Pi / 4
			  Math:Pi / 3
			  Math:Pi / 2) '_ ) }

:Test:Eval-8377N() { Handle(Algorithm:Map(CosA
			  Math:Pi
			  Math:Pi / -2
			  0
			  Math:Pi / 2
			  Math:Pi ) '_ ) }
