Import Gen


; Higher order funtional staples are in Algorithm

Import Algorithm


; List of frequencies

freqs = [330 440 550 660 770 880]


; Map applies a function, Gen:Sin in this case, to all elements in the list.

oscs = Algorithm:Map(Gen:Sin freqs)


; Reduce combines elements of a list, 'oscs' in this case, with the supplied

; function, (+), until the list is folded onto a single value.

f0 = 55

N = #50


; Expand makes 'N' elements by applying (+ f0) repeatedly, starting from f0.

fs = Algorithm:Expand(N (+ f0) f0)

fs


; By the way, (+ x) is a handy way to make an adder function!

Algorithm:Map((+ 100) 1 2 3 4 5)


; Back to business, let's make the oscillators

os = Algorithm:Map(Gen:Sin fs)

; Let's weigh each harmonic by the inverse of its number

is = Algorithm:Expand(N (+ 1) 1)

is


; (1 /) is a handy way to make a function that divides one by a number.

gains = Algorithm:Map((1 /) is)

gains


; Now we have a list of partial sounds, and a list of gains. Two

; lists can be combined element-wise with a binary function by using

; Zip-With.


saw = Algorithm:Zip-With((*) os gains)

Additive(N freq-fn amp-fn) {
	; Generate N partials with the fundamental frequency f0
	; The partial frequencies are derived by freq-fn(i)
	; The partial amplitudes are derived by amp-fn(i)

	; 'Use' lets us make a package prefix implicit
	Use Algorithm

	is = Expand(N (+ 1) 1)
	freqs = Map(freq-fn is)
	amps  = Map(amp-fn is)
	partials = Map(Gen:Sin freqs)

	Reduce((+) Zip-With((*) partials amps))
}


; reproduce our earlier pseudo-sawtooth

; stretching and compressing the harmonic series

stretch = i => 55 * Math:Pow(i 1 + Gen:Sin(0.1))

; per-partial vibrato and amplitude envelope

vibr = i => 55 * i * (Gen:Sin(Math:Sqrt(i)) * 0.1 + 1)

aenv = i => Gen:Sin(1 / i)

; simple exponential decay envelope that starts from 1.

; for each sample, the level is multiplied by a near-one

; coefficient.


Decay(rate) {
	level = z-1(1 level * Gen:Signal(rate))
	level
}


; Let's try it with a single partial

; Now let's make higher partials decay faster

dcy = i => Decay(Math:Pow(0.99999 i / 4)) / i


; Harmonic series sounds a bit like a plucked string

; Inharmonic series sounds like a bell or a metallic object

bfreq = i => 110 * Math:Pow(i 0.75)


:Test:Audio-GkUhR() { snd = Gen:Sin(440) * 0.1 snd }

:Test:Audio-bPx7u() { snd = (Gen:Sin(440) + Gen:Sin(550) + Gen:Sin(660)) * 0.1 snd }

:Test:Audio-ZplEe() { snd = Algorithm:Reduce((+) oscs) / 20 snd }

:Test:Audio-U9lWS() { snd = Algorithm:Reduce((+) os) * 0.2 / N snd }

:Test:Audio-Npwvo() { snd = Algorithm:Reduce((+) saw) * 0.2 snd }

:Test:Audio-t0p8k() { snd = Additive(#50 (* 55) (1 /)) * 0.2 snd }

:Test:Audio-jt6bg() { snd = Additive(#50 stretch i => 1) * 0.02 snd }

:Test:Audio-AmuRS() { snd = Additive(#50 vibr aenv) * 0.02 snd }

:Test:Audio-7mgBo() { snd = Gen:Sin(440) * Decay(0.9999) snd }

:Test:Audio-Im9yw() { snd = Additive(#50 (* 80) dcy) * 0.1 snd }

:Test:Audio-Gs1yw() { snd = Additive(#50 bfreq dcy) * 0.1 snd }

:Test:Eval-lsjPT() { Handle(fs '_ ) }

:Test:Eval-goeHR() { Handle(Algorithm:Map((+ 100) 1 2 3 4 5) '_ ) }

:Test:Eval-tMIIb() { Handle(is '_ ) }

:Test:Eval-wauLu() { Handle(gains '_ ) }
