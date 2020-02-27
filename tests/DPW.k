Import Gen


; slow modulation to emphasize non-harmonic alias terms

sweep = 4000 + 1000 * Gen:Sin(0.2)


phasor = Gen:Phasor(440) * 2 - 1

parabolic = phasor * phasor


; fade back and forth between phasor and squared phasor


fade = Gen:Tri(0.2) * 0.5 + 0.5 
; unipolar triangle osc

Differentiator(sig) {
	; just substract a delayed signal from signal!
	sig - z-1(sig)
}


naive = Gen:Phasor(sweep) * 2 - 1

Import Math


DPW(freq) {
	w = freq * 2 * Math:Pi / Gen:Rate(nil)
	f0g = 2 - 2 * Math:Cos(w)
	phasor = Gen:Phasor(freq) * 2 - 1

	Differentiator(phasor * phasor) / f0g
}



; steady DPW

; demonstrate aliasing by switching back and forth

bad  = Gen:Phasor(sweep) * 2 - 1

good = DPW(sweep)


switch = Gen:Phasor(0.2) > 0.5


; one stage of oversampling for 2x audio rate.

better = Gen:Oversample(#1 { DPW(sweep) } nil)


DPW(freq offset) #[Extend] {
	w = freq * 2 * Math:Pi / Gen:Rate(nil)
	f0g = 2 - 2 * Math:Cos(w)

	; add phase offset here and use Fraction to wrap the phasor back to
	; the [0,1] range.
	phasor = Fraction(Gen:Phasor(freq) + offset) * 2 - 1

	Differentiator(phasor * phasor) / f0g
}


width = Gen:Phasor(0.2)



:Test:Audio-KMY6-() { snd = Gen:Phasor(sweep) * 0.1 snd }

:Test:Audio-KU5S3() { snd = (phasor + fade * (parabolic - phasor)) * 0.2 snd }

:Test:Audio-+EpZ7() { snd = Differentiator(parabolic) * 0.2 snd }

:Test:Audio-YG-Gl() { snd = Differentiator(naive * naive) * 0.1 snd }

:Test:Audio-WhGBn() { snd = DPW(sweep) * 0.1 snd }

:Test:Audio-g60+J() { snd = Algorithm:Choose(switch good bad) * 0.1 snd }

:Test:Audio-Wm-yj() { snd = Algorithm:Choose(switch better good) * 0.1 snd }

:Test:Audio-0Sucy() { snd = (DPW(55) - DPW(55 width)) * 0.1 snd }
