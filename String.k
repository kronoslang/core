Import Algorithm

Package String {
	Brief(documentation) {
		;; Helper functions for textual strings.
		nil
	}

	Concat(strings...) {
		;; Concatenate several values into a string
		Concat = Algorithm:Reduce(String:Append Algorithm:Map(v => Coerce("" v) strings))
	}
}