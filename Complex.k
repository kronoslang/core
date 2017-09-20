Import Dictionary
Import Math

Type Complex

Package Complex{
	Cons(real img) {
		;; Constructs a Complex number from 'real' and 'img'inary parts.
		Cons = Make(:Complex (Type-Check(real Real?) Type-Check(img Real?)))
	}

	Cons-Maybe(real img) {
		;; Constructs a Complex number from 'real' and 'img', provided that they are real numbers.
		Cons-Maybe = When(
			Real?(real) & Real?(img) 
			Make(:Complex real img))
	}

	Maybe(real img) {
		Maybe = When(Real?(real) & Real?(img) Cons(real img))
	}

	Real/Img(c) {
		;; Retrieve Real and/or Imaginary part of a Complex number 'c'.
		(Real Img) = Break(:Complex c)
	}

	Add(a b) {
		;; Adds two complex numbers.
		Add = Cons(Real(a) + Real(b)
				   Img(a) + Img(b))
	}

	Sub(a b) {
		;; Substracts complex 'b' from 'a'.
		Sub = Cons(Real(a) - Real(b)
				   Img(a) - Img(b))
	}

	Mul(a b) {
		;; Multiplies two complex numbers.
		Mul = Cons(Real(a) * Real(b) - Img(a) * Img(b)
				   Real(a) * Img(b) + Img(a) * Real(b))
	}

	Div(z1 z2) {
		;; Divides complex 'z1' by complex 'z2'.
		denom = 1 / Abs-Square(z2)
		nom = z1 * Conjugate(z2)
		Div = Cons(Real(nom) * denom  Img(nom) * denom)
	}

	Conjugate(c) {
		;; Constructs a complex conjugate of 'c'.
		Conjugate = Cons(Real(c), 0 - Img(c))
	}

	Abs-Square(c) {
		;; Computes the square of the absolute value of complex 'c'.
		Abs-Square = Real(c) * Real(c) + Img(c) * Img(c)
	}

	Abs(c) {
		;; Computes the absolute value of complex 'c'.
		Abs = :Math:Sqrt(Abs-Square(c))
	}

	Arg(c) {
		Arg = :Math:Atan2(Img(c) Real(c))
	}

	Polar(angle radius) {
		;; Constructs a complex number from a polar representation: 'angle' in radians and 'radius'.
		Polar = Cons(radius * Math:Cos(angle) radius * Math:Sin(angle))
	}

	Unitary(angle) {
		;; Constructs a unitary complex number at 'angle' in radians.
		Unitary = Cons(Math:Cos(angle) Math:Sin(angle))
	}
	
	Neg(z) {
		;; Negates a complex number 'z'.
		(re im) = (Real(z) Img(z))
		Neg = Cons(:Neg(re) :Neg(im))
	}

	Equal(z1 z2) {
		;; Compares the complex numbers 'z1' and 'z2' for equality.
		Equal = Real(z1) == Real(z2) & Img(z1) == Img(z2)
	}
}

Package Fallback {
	Binary-Op(func name a b) {
		overloads = [ (Add Complex:Add)
					  (Mul Complex:Mul)
					  (Sub Complex:Sub)
					  (Div Complex:Div)
					  (Equal Complex:Equal) ]

		(key overload) = Dictionary:Find(overloads func)

		Binary-Op = When(Equal-Type(Class-Of(a) Complex) & 
						 Equal-Type(Class-Of(b) Complex)
						 :Eval(overload a b))
	}
}

Neg(args) {
	Neg = :Complex:Neg(args)
}

Abs(args) {
	Abs = :Complex:Abs(args)
}

Complex?(z) {
	Complex? = Equal-Type(Class-Of(z) Complex)
}

Number?(z) {
	Number? = When(Complex?(z) True)
}

I = Complex:Cons(0 1)

Package Type-Conversion {
	Explicit(type data) {
		; try again by dropping imaginary part
		Explicit = Recur(type Complex:Real(data))

		; Convert real number to complex
		Explicit = When(
			Equal-Type(Class-Of(type) Complex) 
			Complex:Cons-Maybe(data #0))
	}

	Implicit(type data) {
		; Reals are implicitly upgraded to Complex
		Implicit = When(
			Equal-Type(Class-Of(type) Complex) 
			Complex:Cons-Maybe(data #0))
	}
}

Package Math {
	Log(Z) {
		Use Complex
		Log = Complex:Cons(Log(Abs-Square(Z)) / #2 Arg(Z))
	}

	Exp(Z) {
		Use Complex
		(x y) = (Real(Z) Img(Z))
		Exp = Complex:Polar(y Math:Exp(x)) 
	}
}
