Package IO {
	Stream(key default priority) {
		Stream = External-Stream(key default priority)
	}

	Source(key default priority) {
		Source = Reactive:Resample(
			External(key default)
			Reactive:Tick(priority key))
	}
}

Rate-of(sig) {
	;; Retrieve the sampling rate of 'sig' in Herz
	Rate-of = Reactive:Rate(sig)
}

Interval-of(sig) {
	;; Retrieve the sampling interval of 'sig' in seconds
	Interval-of = #1 / Rate-of(sig)
}

Frequency-Coefficient(sig freq) {
	;; Compute a frequency coefficient for the sample clock of 'sig'; the frequency is multiplied by the sampling interval and becomes a signal source with the chosen sample rate.
 	Frequency-Coefficient = Reactive:Resample(freq * Interval-of(sig) sig)
}

Package Audio {
	Priority = #10
	Clock 	 = Reactive:Tick(Priority "audio")

	Signal(sig) {
		;; Treats 'sig' as an audio signal that updates at the audio rate.
		Signal = Reactive:Resample(sig Clock)
	}

	Input(initialize-channels) {
		Input = IO:Stream("audio" initialize-channels Priority)
	}

	All-Inputs() {
		All-Inputs = 
			Input(Algorithm:Expand(Configuration:Available-Audio-Inputs() '0 0))
	}

	Stereo-In() {
		Stereo-In = Input(0 0)
	}

	Mono-In() {
		Mono-In = Input(0)
	}

	Rate() {
		Rate = Rate-of(Clock)
	}
}

Package Control {
	Fine = Reactive:Downsample(:Audio:Clock #8)
	Clock = Reactive:Downsample(:Audio:Clock #64)
	Coarse = Reactive:Downsample(:Audio:Clock #512)

	Signal(sig) {
		;; Treats 'sig' as a control signal that updates at 1/64 of the audio rate.
		Signal = Reactive:Resample(sig Clock)
	}

	Signal-Fine(sig) {
		;; Treats 'sig' as a control signal that updates at 1/8 of the audio rate.
		Signal-Fine = Reactive:Resample(sig Fine)
	}

	Signal-Coarse(sig) {
		;; Treats 'sig' as a control signal that updates at 1/512 of the audio rate.
		Signal-Coarse = Reactive:Resample(sig Coarse)
	}

	Param(key init) {
		;; Represents an external control parameter keyed as 'key', with the default value of 'init'
		Param = IO:Source(key init #0)
	}

	Rate = 'Rate-of(Signal(0))
	Rate-Fine = 'Rate-of(Signal-Fine(0))
	Rate-Coarse = 'Rate-of(Signal-Coarse(0))
}
