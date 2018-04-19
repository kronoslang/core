Import Algorithm
Import Control-Logic
Import IO
Import Approx

Periodic-Ramp(freq) {
	inc = freq * 1 / Rate-of(Audio:Clock)
	next = z-1(freq - freq wrap + Audio:Signal(inc))
	wrap = next - Floor(next)
	Periodic-Ramp = wrap
}

Taylor-Sin(freq amp) {
	phasor = Periodic-Ramp(freq)
	Taylor-Sin = amp * Approx:Cosine-Shape(Abs(phasor - 0.5) #5)
}

Voice-Priority(midi-bytes voices) {
	map = Algorithm:Map
	expand = Algorithm:Expand
	reduce = Algorithm:Reduce
	choose = Control-Logic:Choose

	; extract MIDI bytes
	(status note-number velocity) = midi-bytes

	; kill note-number if event is note off or note on with 0 velocity
	kill-key = choose(status == 0x80 | (status == 0x90 & velocity == 0i)
					  note-number -1i)
	; new note-number if event is note on and non-zero velocity
	is-note-on = (status == 0x90 & velocity > 0i) 

	; a constant specifying highest possible priority value
	max-priority = 2147483647i

	; lower gate and reduce priority for released voice
	with-noteoff = map((p k v) => (p - (max-priority & (k == kill-key))
					 		 	   k  v & (k != kill-key))
						voices)

	; find oldest voice by selecting lowest priority
	lowest-priority = reduce(Min map(First voices))


	; insert new note 
	Voice-Priority = map((p k v) => choose((p == lowest-priority) & is-note-on  
								   		(max-priority note-number velocity) 
								   		(p - 1i k v))
						 with-noteoff) 
}

MIDI-Allocator(num-voices allocator midi-bytes) {
		; create initial voice allocation with running priorities so that the allocator
		; always sees exactly one voice as the oldest voice
		voice-init = Algorithm:Expand(num-voices (p _ _) => (p - 1i 0i 0i) (0i 0i 0i))

		; generate and clock the voice allocator loop from the MIDI stream
		old-voices = z-1(voice-init Reactive:Resample(new-voices midi-bytes))

		; perform voice allocation whenever the MIDI stream ticks
		new-voices = allocator(midi-bytes old-voices)
		MIDI-Allocator = new-voices
}

Slew-Limiter(sig slew+ slew-) {
	prev-out = z-1(sig - sig out)
	delta = sig - prev-out
	out = prev-out + Max(slew- Min(slew+ delta))
	Slew-Limiter = out
}

FM-Voice(freq gate) {
	env = Slew-Limiter(Audio:Signal(gate) 0.00006 -0.00002)
	mod = Taylor-Sin(freq freq * 8 * env)
	FM-Voice = Taylor-Sin(freq + mod env)
}

Package Test {
	Voice-Allocator() {
		; create external input for MIDI and mask off bytes from a 24-bit word
		midi = IO:Source("MIDI" 0i #1)
		status = BitShiftRight(midi 16i) & 0xf0 ; ignore channel nibble
		a = BitShiftRight(midi 8i) & 0xff       
		b = midi & 0xff

		; MIDI voice allocator
		voices = MIDI-Allocator(#3 Voice-Priority status a b)
		
		; make a simple synth with the voice allocator
		synth = Algorithm:Reduce((+) Algorithm:Map((idx key gate) => 
				FM-Voice(440 * Math:Pow(2 (key - 69) / 12) gate / 128) voices))

		Voice-Allocator = synth
	}
}