Import Algorithm
Import Complex
Import Lazy
Import Math
Import Exception

Package FFT {
	Cooley-Tukey(N dir Xs) {
		Use Lazy
		half = N / #2

		recur = 'Cooley-Tukey(_)
		even  = recur(half dir Lazy:Stride(#2 Xs))
		odd   = recur(half dir Lazy:Stride(#2 Rest(Xs)))

		twiddle-factor = Complex:Polar((dir * Math:Pi / N) * #2 #1) * 1
		twiddled = Multi-Map(Mul [odd Series:Geometric(Complex:Cons(1 0) twiddle-factor)])

		merge = Concat(
			Force(Take(half Multi-Map(Add [even twiddled])))
			Force(Take(half Multi-Map(Sub [even twiddled]))))

		(x1 x2 _) = Xs
		Cooley-Tukey = 
			Debug-Trace("fft " N)  < #1 : Throw:Invalid-Argument("Cooley-Tukey FFT requires a power-of-two array input")
			N == #1 : [First(Xs)]
			N == #2 : [x1 + x2 x1 - x2]
				Force(merge)	
	}

	Skip(Xs) {
		Skip = []
		Skip = When(Nil?(Rest(Xs)) [First(Xs)])
		(x1 x2 xs) = Xs
		Skip = (x1 Recur(xs))
	}

	SRecur(dir Xs) {
		SRecur = Cooley-Tukey-S(dir Xs)
	}

	Cooley-Tukey-S(dir Xs) {
		Use Algorithm		
		N =    Arity(Xs)
		even = SRecur(dir Skip(Xs))
		odd  = SRecur(dir Skip(Rest(Xs)))

		twiddle-factor = Complex:Polar((dir * Math:Pi / N) * #2 #1) * 1
		twiddle = Zip-With(Mul odd Expand(N / #2 (* twiddle-factor) Complex:Cons(1 0)))

		(x1 x2 _) = Xs

		Cooley-Tukey-S = 
			N  < #1 : Throw:Invalid-Argument("Cooley-Tukey FFT requires a power-of-two array input")
			N == #1 : [First(Xs)]
			N == #2 : [x1 + x2 x1 - x2]
				Concat(
					Zip-With(Add even twiddle)
					Zip-With(Sub even twiddle))				
	}

	Forward(Xs) {
		Forward = Cooley-Tukey-S(#1 Xs)
	;	Forward = Cooley-Tukey(Arity(Xs) #1 Lazy:View(Xs))
	}

	Inverse(Xs) {
		Inverse = Cooley-Tukey(Arity(Xs) #-1 Lazy:View(Xs))
	}
}