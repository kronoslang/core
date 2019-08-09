Import Algorithm

Package Control {
	Sample-and-Hold(sig hold) {
		;; When `hold` is true, freeze the value of `sig`nal.
		state = z-1(sig Algorithm:Choose(hold state sig))
		state
	}

	Edge+(sig) {
		;; True when `sig` contains an upward edge
		sig > z-1(sig)
	}

	Edge-(sig) {
		;; True when `sig` contains a downward edge
		sig < z-1(sig)
	}

	Edge+-(sig) {
		;; True when the value of `sig` changes
		sig != z-1(sig)
	}
}