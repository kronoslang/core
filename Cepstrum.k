Import Complex

Package Cepstrum {
	Pack-Complex(interleaved) {
		(re im is) = interleaved
		Pack-Complex = Nil?(interleaved) : nil (Complex:Cons(re im) Recur(is))
	}

	Unpack-Complex(packed) {
		(c cs) = packed

		re = Coerce(Float Complex?(c) : Complex:Real(c) c)
		im = Coerce(Float Complex?(c) : Complex:Img(c) c - c)

		Unpack-Complex = Nil?(packed) : packed (re im Recur(cs))
	}

	FFT(sig) {
		raw = Unpack-Complex(sig)
		(_ raw-out _) = Foreign-Function["int32" "kissfft" 
			"float*" raw
			"int32" Coerce(Int32 Arity(sig))
			"int32" 0i]
		norm = Math:Sqrt(#1 / Arity(sig))
		FFT = Pack-Complex(Algorithm:Map((* norm) raw-out))
	}

	IFFT(sig) {
		raw = Unpack-Complex(sig)
		(_ raw-out _) = Foreign-Function["int32" "kissfft" 
			"float*" raw
			"int32" Coerce(Int32 Arity(sig))
			"int32" -1i]
		norm = Math:Sqrt(#1 / Arity(sig))
		IFFT = Pack-Complex(Algorithm:Map((* norm) raw-out))			
	}

	From-Real-Spectrum(s) {
		clip = Math:Pow(10 -100 / 20)
		From-Real-Spectrum = 
			IFFT(Algorithm:Map(x => Complex:Cons(Math:Log(Max(clip x)) 0) s))
	}

	To-Real-Spectrum(cps) {
		To-Real-Spectrum = 
			Algorithm:Map(Math:Exp FFT(cps))
	}

	MPS(linear-spectrum) {
		Use Algorithm

		MPS = Raise("failed")
		
		nt = Arity(linear-spectrum) / #2
		swap  = (a b) => (b a)

		cps    = From-Real-Spectrum(linear-spectrum)
		pos    = Take(nt - #1 Rest(cps))
		neg    = Reduce(swap Map(Complex:Conjugate Take(nt - #1 Skip(nt + #1 cps))))
		causal = Concat(
					(First(cps) Zip-With(Add pos neg))
				 	 Expand(nt '_ Complex:Cons(0 0)))
		MPS    = To-Real-Spectrum(causal)
	}
}