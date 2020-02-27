; change this to whatever the path is on your system:

path = "/Users/vnorilo/sounds/countdown.wav"


; obtain audio data

(waveform-sr waveform-frames waveform) = Audio:File(path)


; sample rate

waveform-sr

; number of frames (samples) in file

waveform-frames

; audio data function wrapper

waveform

Import Gen


; drive audio read head from an oscillator

pos = waveform-sr * 3 * (1 + Gen:Sin(1 / 16))

Import Function


waveform-ip = Function:Wrap-Hermite(waveform)


; waveform-ip is a function just like waveform, but samples

; four points in the source function in order to provide

; a smoothly interpolated curve.


; Use seconds instead of samples as audio timebase. We can do this

; by composing a multiplication in front of the interpolated

; waveform function.


waveform-t = Function:Compose(waveform-ip (* waveform-sr))


; Simple parabolic envelope for level that is

; nonzero between 0 and 1, peaking with unity at 0.5.

Parabolic = t => Max(0 #4 * (t - t * t))


Algorithm:Map(Parabolic 0 0.25 0.5 0.75 1)


; Derive timeline from a phasor; let's use a simple

; periodic ramp from 0 to 1 at 1Hz.

grain-rate = 5


time = Gen:Phasor(grain-rate)


grain-pos = 5.8 + time * (1 / grain-rate)


; We can change envelope duration like so:


dur = 0.01 + Gen:Phasor(0.25)

; Or modulate the grain rate


grain-rate' = 1 + 30 * Gen:Phasor(0.2)

time' = Gen:Phasor(grain-rate')

grain-pos' = 5.8 + time' * (1 / grain-rate')

Import Control


Grain-Read-Point(seq phase start rate) {

	; Compute audio sample interval for read speed, and
	; multiply by the rate parameter
	inc = Interval-of(Audio:Signal(0)) * rate

	; advance read head and update read head
	; location at audio rate
	next-pos = Audio:Signal(pos + inc)

	; identify new grain by detecting upward
	; edges in the seq signal, which represents
	; the grain identifier
	new-grain? = Control:Edge+(seq)

	; for new grains, reset position to the start
	; parameter, otherwise allow read head to advance
	; normally.
	pos = Algorithm:Choose(
			new-grain?
				start
				z-1(0 next-pos))

	; finally, output the read head location
	pos
}

Stretch-Grain(source-fn timeline rate ratio) {

	; grain seq id: integer part of timeline
	seq = Floor(timeline)

	; grain phase: fraction of timeline
	phase = Min(1 timeline - seq)

	; generate grain read position
	pos = Grain-Read-Point(
		seq phase
		seq * (ratio / rate)
		#1)

	; sample source function at that position,
	; and apply envelope at current phase
	source-fn(pos) * Parabolic(phase)
}


; 8 grains per second

timeline = Gen:Ramp(0 8)

Stretch(source-fn rate ratio voices) {
	Use Algorithm

	; spread grain stream offsets equidistantly between
	; zero and 1.
	offsets = Expand(voices (+ (1 / voices)) 0)

	; generate timeline for all grains
	t = Gen:Ramp(0 rate)

	; for each voice, generate grains.
	; offsets are produced by subtracting the offset
	; from the timeline value.
	v = Map(o => Stretch-Grain(source-fn t - o rate ratio) offsets)

	; sum voices and compensate volume by dividing with
	; the square root of polyphony count
	Reduce((+) v) / Math:Sqrt(voices)
}


; let's modulate the stretch ratio with a ramp

ramp = 0.1 + Gen:Phasor(0.08)

r3 = ramp * ramp * ramp


voices = #4


; 16 grains per second, 4 overlapping streams

Grain(timeline source-fn start rate-env amp-env) {

	; compute sequential grain id and phase as before
	seq = Control:Signal(Coerce(Int32 timeline))
	phase = Min(1 timeline - seq)

	; detect new grain
	new-grain? = Control:Edge+-(seq)

	; this is our grain closure that captures rate-env
	; and amp-env. Please note that it's important *not*
	; to capture seq and phase, or those too would be
	; immutable during a grain.

	grain-proto(seq phase) {
		rate = rate-env(phase)
		pos = Grain-Read-Point(seq phase start rate)
		source-fn(pos) * amp-env(phase)
	}

	; if we have a new grain starting, admit a new prototype
	; into the grain synthesizer. this prototype has captured
	; rate-env and amp-env as they were upon grain start.
	grain = Control:Sample-and-Hold(grain-proto new-grain?)

	; synthesize!
	grain(seq phase)
}


; test bench

Test(rate) {
	; simulate randomized read position with a complex
	; long-preiod modulator (product of non-aligned sines)
	pos = 6 + 6 * Gen:Sin(0.02) * Gen:Sin(0.07)

	; modulate grain rates by generating an unsteady timeline
	timeline = Gen:Ramp(0 rate * (1 + 0.5 * Gen:Tri(rate * 0.1)))

	; this will be a per-grain parameter. the modulator runs here
	; and the captured value will be held by the grain prototype
	transp = 1 + 0.5 * Gen:Sin(9) * Gen:Sin(11)

	; rate-env is a trivial closure over transp, and
	; Parabolic is the amplitude envelope.
	Grain(timeline waveform-t pos () => transp Parabolic)
}



:Test:Audio-D1ceD() { snd = waveform(pos) snd }

:Test:Audio-H1oj6() { snd = waveform-ip(pos) snd }

:Test:Audio-Tilt2() { snd = waveform-t(1 + Gen:Sin(0.25)) snd }

:Test:Audio--ZIfS() { snd = waveform-t(grain-pos) * Parabolic(time) snd }

:Test:Audio-INiG9() { snd = waveform-t(grain-pos) * Parabolic(time / dur) snd }

:Test:Audio-tab3o() { snd = waveform-t(grain-pos') * Parabolic(time' * 2) snd }

:Test:Audio-VEhcU() { snd = Stretch-Grain(waveform-t timeline 8 0.5) snd }

:Test:Audio-p1lhS() { snd = Stretch(waveform-t 16 r3 * 4 voices) snd }

:Test:Audio-7jaaj() { snd = Algorithm:Reduce(
		(+)
		Algorithm:Map(
			Test
			11 13 17 21 29)) snd }

:Test:Eval-iMWyG() { Handle(waveform-sr '_ ) }

:Test:Eval-OarTw() { Handle(waveform-frames '_ ) }

:Test:Eval-U0inT() { Handle(waveform '_ ) }

:Test:Eval-ogl8o() { Handle(Algorithm:Map(Parabolic 0 0.25 0.5 0.75 1) '_ ) }
