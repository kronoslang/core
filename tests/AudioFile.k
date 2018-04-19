Import IO

Iterative(step-function initializer) {
	state = step-function(z-1(initializer Audio:Make-Signal(state)))
	Iterative = state
}


Package Test {
	url = "g:/maalari.wav"
	Audio-File() {
		file = IO:Stream("audio-file" url)
		pos = Iterative((+ 1i) 0i)
		Audio-File = Select-Wrap(file pos)
	}

	Audio-File-Reverse() {
		file = IO:Stream("audio-file" url)
		pos = Iterative((- 1i) 0i)
		Audio-File-Reverse = Select-Wrap(file pos)
	}
}
