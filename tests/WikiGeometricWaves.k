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
    Saw = #2 - Phasor(freq) * #2
}

Tri(freq) {
    Tri = #2 * Abs(Saw(freq)) - #1
}

Pulse(freq width) {
    Pulse = #2 * ( (Phasor(freq) < width) & 1 ) - #1
}
