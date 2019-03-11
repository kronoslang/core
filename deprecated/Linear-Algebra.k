Import Algorithm

Package Matrix {
	Brief(documentation) {
		;; Defines linear algebra primitives.
		nil
	}

	Type Matrix

	Cons(rows) {
		;; Constructs a matrix from a set of 'rows'.
		Use Algorithm

		Cons = Invalid-Function()
		a1 = Arity(First(rows))
		Cons = When(Every((== a1) Map(Arity rows)) 
					Make(Matrix rows))
	}

	Rows(mtx) {
		Rows = Arity(Break(Matrix mtx))
	}

	Cols(mtx) {
		Cols = Arity(First(Break(Matrix mtx)))
	}

	Transpose(matrix) {
		;; Transposes the 'matrix'.
		map = Algorithm:Map
		Transpose = Nil?(First(matrix)) : nil
					(map(First matrix) Recur(map(Rest matrix)))

		Transpose = Make(Matrix Recur(Break(Matrix matrix)))
	}

	Mul(a b) {
		;; Multiplies matrices 'a' and 'b'.
		amap = Algorithm:Map 
		ared = Algorithm:Reduce 
		azip = Algorithm:Zip-With
		Mul = amap(col => 
				amap(row => ared(Add azip(:Mul col row)) 
					a) Transpose(b))

		Mul = Make(Matrix Recur(Break(Matrix a) b))
		Mul = Make(Matrix Recur(a Break(Matrix b)))
		Mul = Make(Matrix Recur(Break(Matrix a) Break(Matrix b)))
	}

	Hadamard-Product(a b) {
		;; Computes the Hadamard product of matrices 'a' and 'b'.
		Use Algorithm
		Hadamard-Product = Zip-With('Zip-With(:Mul _) a b)
	}

	Element(mtx col row) {
		;; Retrieves an element of matrix 'mtx' at 'row' and column 'col', where 'row' and 'col' are zero-based invariant constants.
		Element = Nth(col Nth(row mtx))
		Element = Recur(Break(Matrix mtx) col row)
	}

	Map(func mtx) {
		;; Applies function 'func' to all elements of matrix 'mtx', returning the resulting matrix.
		amap = Algorithm:Map
		Map = amap(row => amap(func row) mtx)
		Map = Recur(func Break(Matrix mtx))
	}

	Pseudo-Inverse(mtx) {
		inverse = Transpose(mtx)	
		(_ Pseudo-Inverse _) = Foreign-Function["int32" "eigen_pinv" 
			"float*" Break(Matrix inverse) 
			"const float*" Break(Matrix mtx)
			"int32" Coerce(Int32 Rows(mtx))
			"int32" Coerce(Int32 Cols(mtx))]
	}
}
