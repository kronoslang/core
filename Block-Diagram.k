Import Algorithm

Package Block-Diagram {
	Brief(documentation) {
		;; Defines primitives to combine signal processors in parallel, series and recursively.
		nil
	}

	Serial(a b) {
		;; route 'a' and 'b' serially, from left to right
		Serial = { b(a(arg)) }
	}

	Pipe(blocks...) {
		Pipe = in => Algorithm:Reduce((sig block) => Eval(block sig) in blocks...)
	}

	Parallel(a b) {
		;; route 'a' and 'b' parallel: each block will receive and send one element in a multichannel signal
		Parallel = { (c d) = arg (a(c) b(d)) } 
	}

	Vector(blocks...) {
		Vector = 'Algorithm:Zip-With(Eval blocks... arg)
	}

	Split(a b) {
		;; route the output of 'a' to both inputs of 'b'
		Split = Serial(Serial(a '(_ _)) b)
	}

	Bank(block) {
		;; creates a bank of 'block's, with a number of blocks determined by the input signal
		Bank = 'Algorithm:Map(block _)
	}

	Recursive(a b) {
		;; creates a Recursive routing for the binary function 'a', routing its output back to its first input through 'b'. The resulting composition is unary, and the argument signal is fed into the second input of 'a'.
		recursively = { 
			(sig fn) = arg
			st = z-1(sig upd) 
			upd = fn(st)
			upd
		}

		Recursive = in => recursively(in fb => a(b(fb) in))
	}

	Wire(x) {
		Wire = x
	}

	Infix-> = Serial
	Infix|| = Parallel
	Infix-< = Split
	Infix~ = Recursive	
}