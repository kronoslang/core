Cycle(init func) {
	;; Route the output of 'func' back to its argument through a unit delay. Initialize the delay to 'init'.
	st = z-1(init func(st))
	st
}

Audio-Cycle(init func) {
	;; Route the output of 'func' back to its argument through a unit delay. The feedback is upsampled to audio rate. The unit delay is initialized to 'init'
	st = z-1(init Audio:Signal(func(st)))
	st
}

Control-Cycle(init func) {
	;; Route the output of 'func' back to its argument through a unit delay. The feedback is upsampled to control rate. The unit delay is initialized to 'init'
	st = z-1(init Control:Signal(func(st)))
	st	
}

Async-Cycle(init funcs) {
	st = Reactive:Resample(
			z-1(sig - sig 
				Merge-Updates(
					Algorithm:Map(t => t(state sig) funcs))) sig)

	st
}