Import Gen

Package Control {
	Beat(bpm steps) {
		phase = Gen:ULFO(Wave:Saw bpm / 60)
		Beat = Floor(phase * steps)
	}

	Seq(bpm notes) {
		Seq = Select(notes Beat(bpm Arity(notes)))
	}
}

