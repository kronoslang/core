Import IO

Package Tests {
	Stream-Out() {
		Stream-Out = IO:Source("in" 0 #0)
	}

	Streaming-Sum() {
		Streaming-Sum =
			IO:Source("a" 0 #0) +
			IO:Source("b" 0 #0)
	}
}