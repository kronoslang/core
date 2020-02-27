Phasor(freq) {
    ; compute the increment per sample by normalizing frequency to 0 - Nyquist/2
    ; inject audio clock with 'Audio:Signal'
    inc = Audio:Signal( freq / Audio:Rate( ) )

    ; compute integration by recursive unit delay (z-1). The feedback loop is computed
    ; by adding 'inc' to the previous value 'state', and wrapping back at 1.
    state = z-1( Fraction(state + inc) )

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



:Test:Audio-x7ao6() { snd = Phasor(220) * 0.1 snd }

:Test:Audio-U1o-b() { snd = Saw(220) * 0.1 snd }

:Test:Audio-3uSoF() { snd = Tri(220) * 0.1 snd }

:Test:Audio-+3jqG() { snd = Pulse(220 0.5 + 0.5 * Tri(0.1)) * 0.1 snd }
