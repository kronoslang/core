Import Cycle
Import Interpolation
Import Actions

Package Sound-File {
	Data(url) {
		External-Data("PAFGetDataSource" "audio-file" url)
	}

	Hermite-Selector(playhead data selector) {
		smps = Algorithm:Map( { 
				frame = selector(data playhead + arg)
				Arity(frame) > #1 : Vector:Pack(frame) frame
			} -1 0 1 2)

		N = Arity(First(data))

		N > #1 : 
			Vector:Unpack(Interpolation:Hermite(Vector:Broadcast(N Fraction(playhead)) smps))
			Interpolation:Hermite(Fraction(playhead) smps)
	}

	Hermite-Select(playhead data) {
		Hermite-Selector(playhead data Select)
	}

	Hermite-Select-Wrap(playhead data) {
		Hermite-Selector(playhead data Select-Wrap)
	}

	Blit(url) {
		playhead = Audio-Cycle(0i (+ 1i))
		(sr data) = Data(url)
		Select-Wrap(playhead data)
	}

	Loop(url rate) {
		Use Algorithm
		(sr data) = Data(url)
		inc = rate * sr / Audio:Rate()

		playhead = Audio-Cycle(0 {
			next = arg + inc
			Choose(next >= Arity(data) 0 next)
		})

		Hermite-Select(playhead data)
	}

	Loop-Section(url rate start end) {
		Use Algorithm

		(sr data) = Data(url)
		inc = rate * sr / Audio:Rate()

		playhead = Audio-Cycle(0 {
			next = arg + inc
			Choose(next >= sr * end (next + (start - end) * sr) next)
		})

		Hermite-Select(playhead data)
	}

	Play(url rate offset) {
		(sr data) = Data(url)
		inc = rate * sr / Audio:Rate()
		playhead = Audio-Cycle(offset * sr (+ inc))
		Hermite-Select(playhead data)
	}

	Trigger(url rate offset) {
		Use Actions

		(sr data) = Data(url)
		len = data / sr

		Do(
			PrintLn("Playing!")

			playback <- Start({ Play(url rate offset) })

			After(
				(len - offset) / rate 
				Stop(playback) ) 
		)
	}
}
