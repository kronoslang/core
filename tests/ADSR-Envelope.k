Attack = 0.3

Decay  = 0.3

Sustain = 0.4

Release = 0.3


; use control rate for the envelope.

; substitute Audio:Signal for audio rate envelopes.


tick = Control:Signal


; number of control frames per second

fps = Reactive:Rate(tick(0))


; attack and decay rate per frame

ar  = 1 / (Attack * fps)

dr  = 1 / (Decay  * fps)


; build envelope segments as tuples of rate and initial y-value

env = [(ar 0)
       (dr 1)
       (0  Sustain)]


bpf(trigger segments) {
  ; retrieve envelope segment
  (rate current) = Select(segments position)
  (_    target)  = Select(segments position + 1)

  ; position increases by 'rate', but is brought to
  ; zero by the bitwise and operator (&) when 'trigger'
  ; flag is high

  position = z-1(tick((position + rate) & Not(trigger)))

  ; compute current value with linear interpolation
  current + (position - Floor(position)) * (target - current)
}

Import Gen


; Use a comparator to cook a trigger signal and resample to control rate


trigger = tick(Wave:Saw(0.5) > 0)


slew(gate release-rate) {
  ; limit the downward slope by preventing the value from
  ; going below previous value minus the release rate.
  current = Max(gate z-1(current - release-rate))

  slew = current
}



; varying-width pulse wave for triggering the envelope

gate        = tick(Wave:Saw(1) < Wave:Saw(0.1)) & 1


; Release envelope via slew-limiting the downward slope of the gate signal

rel-env     = slew(gate 1 / (Release * fps))


; Retrigger mask is obtained by detecting upward edges of the gate signal

ads = bpf(gate > z-1(gate) env)


; Total envelope is the product of the ADS envelope and the Release envelope

; uses slew and bpf


ADSR(gate attack decay sustain release) {
  ; use control rate for the envelope.
  tick = Control:Signal

  ; number of control frames per second
  fps = Reactive:Rate(tick(0))

  ; attack, decay and release rate per frame
  (ar dr rr) = Algorithm:Map(d => 1 / (d * fps) attack decay release)

  ; build envelope segments as tuples of rate and initial y-value
  env = [(ar 0)
         (dr 1)
         (0  sustain)]

  ; ensure 'gate' ticks at control rate
  cgate = tick(gate)

  ; compute envelope as a product of ADS and release envelopes
  bpf(cgate > z-1(cgate) env) * slew(cgate rr)
}


; use simple parabolic shape for the amplitude coefficient

e   = ADSR(gate 0.05 0.15 0.5 0.3)


:Test:Audio-pCbmb() { snd = Wave:Saw(110) * bpf(trigger env) snd }

:Test:Audio-xy5Ax() { snd = Wave:Saw(110) * rel-env snd }

:Test:Audio-qGU4I() { snd = Wave:Saw(110) * ads * rel-env snd }

:Test:Audio-ze1SA() { snd = Wave:Saw(110) * e * e snd }
