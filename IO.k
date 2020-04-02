Package IO {
	Stream(key default priority) {
		Stream = External-Stream(key default priority key)
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

Cache(data) {
	(Cache _) = Reactive:Couple(data Reactive:Tick(#-100 "once"))
}

Frequency-Coefficient(sig freq) {
 	Frequency-Coefficient = Reactive:Resample(freq * Interval-of(sig) sig)
}

Package Audio {
	Priority = #10
	Clock 	 = Reactive:Tick(Priority "audio")

	Signal(sig) {
		;; Upsample `sig` to the audio rate.
		Signal = Reactive:Resample(sig Clock)
	}

	Input(initialize-channels) {
		Input = IO:Stream("audio" initialize-channels Priority)
	}

	Device-Inputs = (0 0)
	Inputs = Device-Inputs

	All-Inputs() {
		All-Inputs = Input(Inputs)
	}

	Device-Outputs = (0 0)
	Outputs = Device-Outputs

	Stereo-In() {
		Stereo-In = Vector:Pack(Input(0 0))
	}

	Mono-In() {
		Mono-In = Input(0)
	}

	Rate() {
		Rate = Rate-of(Clock)
	}

	File(path) {
		;; Load a sound file at 'path', returning a tuple of (sample-rate frames function), where function samples the audio file at integer positions.
		(sr frames) = Break(Audio-File-Tag External-Asset(path))
		(sr
		 Arity(frames)
		 {
			(_ frames) = Break(Audio-File-Tag External-Asset(path))
			out = Select(frames arg)
			Pair?(out) : Vector:Cons(out) out
		 })
	}

	Loop(path) {
		;; Load a sound file at 'path', returning a tuple of (sample-rate function), where function samples the audio file at integer positions. The file is exposed as an infinite cyclic loop.
		(sr frames) = Break(Audio-File-Tag External-Asset(path))
		(sr
		 Arity(frames)
		 {
			(_ frames) = Break(Audio-File-Tag External-Asset(path))
			out = Select-Wrap(frames arg)
			Pair?(out) : Vector:Cons(out) out
		 })
	}
}

Package Control {
	Fine = Reactive:Downsample(:Audio:Clock #8)
	Clock = Reactive:Downsample(:Audio:Clock #64)
	Coarse = Reactive:Downsample(:Audio:Clock #512)

	Signal(sig) {
		;; Resample `sig` to control rate (1/64 audio)
		Signal = Reactive:Resample(sig Clock)
	}

	Signal-Fine(sig) {
		;; Resample `sig` to fine control rate (1/8 audio)
		Signal-Fine = Reactive:Resample(sig Fine)
	}

	Signal-Coarse(sig) {
		;; Resample `sig` to coarse control rate (1/512 audio)
		Signal-Coarse = Reactive:Resample(sig Coarse)
	}

	Param(key init) {
		Param = IO:Source(key init #0)
	}

	Rate = 'Rate-of(Signal(0))
	Rate-Fine = 'Rate-of(Signal-Fine(0))
	Rate-Coarse = 'Rate-of(Signal-Coarse(0))
}
