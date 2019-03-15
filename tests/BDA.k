Import Block-Diagram
Import Gen
Use Block-Diagram

Convolution(sig coefs) {
    (c cs) = coefs
    z = sig - sig
    Convolution = Nil?(coefs) : #0 sig * coefs
    Convolution = sig * c + Convolution(z-1(z sig) cs)
}

Conv = coefs => ('Convolution(_ coefs))

Biquad = (a1 a2 b0 b1 b2) => ( ( Add ~ Conv(a1 a2) ) -> Conv(b0 b1 b2) )

Resonator(freq bw) {
    w = #2 * Math:Pi * freq / Audio:Rate()
    r = Math:Exp(Neg(Math:Pi * bw / Audio:Rate()))
    norm = (#1 - r * r)
    Resonator = Biquad(#2 * r * Math:Cos(w)
                       Neg(r * r)
                       norm #0 Neg(norm))
}

Import Gen
noise = 'Noise:Pseudo-White(0.499d)

Package Test {
	Faust-Biquad() {
		process = noise -< ( Resonator(440 10) || Resonator(550 10) ) -> Add
		Faust-Biquad = process()
	}
}
