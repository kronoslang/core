Phasor(freq) {
    ; compute the increment per sample by normalizing frequency to 0 - Nyquist/2
    ; inject audio clock with 'Audio:Signal'
    inc = Audio:Signal( freq / Audio:Rate( ) )

    ; wrap the phasor around at 1
    wrap = x => x - Floor(x)

    ; compute integration by recursive unit delay (z-1). The feedback loop is computed
    ; by adding 'inc' to the previous value 'state', and wrapping back at 1.
    ; the purpose of 'freq - freq' is to initialize the feedback loop: this computation
    ; expresses zero in the data type of 'freq'.
    state = z-1( freq - freq  wrap(state + inc) )

    ; function return value
    Phasor = state
}

Saw(freq) {
    Saw = #1 - Phasor(freq) * #2
}

Tri(freq) {
    Tri = #2 * Abs(Saw(freq)) - #1
}

Pulse(freq width) {
    Pulse = #2 * ( (Phasor(freq) < width) & 1 ) - #1
}

Import Algorithm

Sine-Params(n f0 fd ad) {
    ; n  - number of partials to generate. must be invariant constant (eg. #50)
    ; f0 - fundamental frequency
    ; fd - spectral spread, 1 for harmonic series
    ; ad - spectral amplitude decay coefficient, 1 for no decay

    Use Algorithm

    ; Generate harmonic indices; from 0 to n-1
    is    = Expand(n (+ 1) 1)

    ; Produce a frequency from harmonic index: f0 + i * fd^i
    freqs = Map(i => f0 * Math:Pow(fd i) * i is) 

    ; Generate amplitudes as a geometric series starting from 1,
    ; with factor of 'ad'
    amps  = Expand(n (* ad) 1)

    ; 'zip' the frequency and amplitude lists, so that each element
    ; is a pair of a single frequency and amplitude.
    Sine-Params = Zip(freqs amps)
}

Import Gen

Bank(n f0 fd ad) {
    Use Algorithm

    ; generate control parameters
    params = Sine-Params(n f0 fd ad)

    ; generate sinusoids with a digital waveguide algorithm
    oscs = Map((freq amp) => amp * Wave:Sin-DWG(freq) params)

    ; sum sinusoids and normalize amplitudes
    Bank = Reduce((+) oscs) / n
}

Package Test {
    Geometric-Waves() {
        lfo1 = 0.5 + 0.4 * Tri(0.1)
        lfo2 = 0.5 + 0.4 * Tri(0.11)
        Geometric-Waves = (
            Pulse(110 lfo1) * 0.5
            Pulse(109.5 lfo2) * 0.5
            )
    }

    Sine-Bank() {
        lfo1 = 0.8 + 0.2 * Tri(0.25)
        lfo2 = 0.5 + 0.4 * Tri(1)
        Sine-Bank = Bank(#20 110 lfo1 lfo2)
    }
}
