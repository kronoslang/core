Import Math

Type Complex

Package Complex{
	Brief(documentation) {
		;; Defines complex-number type and arithmetic.
		nil
	}

	Cons(real:Real! img:Real!) {
		;; Constructs a Complex number from 'real' and 'img'inary parts.
		Cons = Make(:Complex real img)
	}

	Cons-Maybe(real img) {
		;; Constructs a Complex number from 'real' and 'img', provided that they are real numbers.
		Cons-Maybe = When(
			Real?(real) & Real?(img)
			Make(:Complex real img))
	}

	Real/Img(c:Complex!) #[Pattern] {
		;; Retrieve Real and/or Imaginary part of a Complex number 'c'.
		(Real Img) = Break(:Complex c)
	}

	Add(a:Complex! b:Complex!) {
		;; Adds two complex numbers.
		Add = Cons(Real(a) + Real(b)
				   Img(a) + Img(b))
	}

	Sub(a:Complex! b:Complex!) {
		;; Substracts complex 'b' from 'a'.
		Sub = Cons(Real(a) - Real(b)
				   Img(a) - Img(b))
	}

	Mul(a:Complex! b:Complex!) {
		;; Multiplies two complex numbers.
		Mul = Cons(Real(a) * Real(b) - Img(a) * Img(b)
				   Real(a) * Img(b) + Img(a) * Real(b))
	}

	Div(z1:Complex! z2:Complex!) {
		;; Divides complex 'z1' by complex 'z2'.
		denom = 1 / Abs-Square(z2)
		nom = z1 * Conjugate(z2)
		Div = Cons(Real(nom) * denom  Img(nom) * denom)
	}

	Conjugate(c:Complex!) {
		;; Constructs a complex conjugate of 'c'.
		Conjugate = Cons(Real(c), 0 - Img(c))
	}

	Abs-Square(c:Complex!) #[Pattern] {
		;; Computes the square of the absolute value of complex 'c'.
		Abs-Square = Real(c) * Real(c) + Img(c) * Img(c)
	}

	Abs(c:Complex!) #[Pattern] {
		;; Computes the absolute value of complex 'c'.
		Abs = :Math:Sqrt(Abs-Square(c))
	}

	Arg(c:Complex!) #[Pattern] {
		Arg = :Math:Atan2(Img(c) Real(c))
	}

	Polar(angle:Real! radius:Real!) {
		;; Constructs a complex number from a polar representation: 'angle' in radians and 'radius'.
		Polar = Cons(radius * Math:Cos(angle) radius * Math:Sin(angle))
	}

	Unitary(angle:Real!) {
		;; Constructs a unitary complex number at 'angle' in radians.
		Unitary = Cons(Math:Cos(angle) Math:Sin(angle))
	}

	Neg(z:Complex!) #[Pattern] {
		;; Negates a complex number 'z'.
		(re im) = (Real(z) Img(z))
		Neg = Cons(:Neg(re) :Neg(im))
	}

	Equal(z1:Complex! z2:Complex!) {
		;; Compares the complex numbers 'z1' and 'z2' for equality.
		Equal = Real(z1) == Real(z2) & Img(z1) == Img(z2)
	}
}

Package Fallback {
	Binary-Op(func name a b) #[Extend] {
		overloads = [ (Add Complex:Add)
					  (Mul Complex:Mul)
					  (Sub Complex:Sub)
					  (Div Complex:Div)
					  (Equal Complex:Equal) ]

		(key overload) = Algorithm:Some((k o) => (k ==t func) overloads)

		Binary-Op = When(Equal-Type(Class-of(a) Complex) &
						 Equal-Type(Class-of(b) Complex) &
						 Not(Nil?(overload))
						 :Eval(overload a b))
	}
}

Neg(args:Complex!) #[Extend] {
	Neg = :Complex:Neg(args)
}

Abs(args:Complex!) #[Extend] {
	Abs = :Complex:Abs(args)
}

Complex?(z) {
	Complex? = Equal-Type(Class-of(z) Complex)
}

Vectorize-Type?(z) #[Extend] {
	Class-of(z) ==t Complex
}


I = Complex:Cons(#0 #1)

Package Type-Conversion {
	Explicit(type data) #[Extend] {
		; Convert complex number by dropping imaginary part
		Explicit = Recur(type Complex:Real(data))

		; Convert real number to complex
		Explicit = When(
			Equal-Type(Class-of(type) Complex)
			Complex:Cons-Maybe(
				Type-Conversion:Upgrade(Complex:Real(type) data)
				Type-Conversion:Upgrade(Complex:Img(type) #0)))
	}

	Implicit(type data) #[Extend] {
		; Reals are implicitly upgraded to Complex
		Implicit = When(
			Equal-Type(Class-of(type) Complex)
			Complex:Cons-Maybe(
				Type-Conversion:Upgrade(Complex:Real(type) data) 
				Type-Conversion:Upgrade(Complex:Img(type) #0)))
	}
}

Package Constraints {
	Complex!(z) #[Pattern] {
		When(Complex?(z) z)
	}
}

Package Math {
	Log(Z:Complex!) #[Extend] {
		Use Complex
		Log = Complex:Cons(Log(Abs-Square(Z)) / #2 Arg(Z))
	}

	Exp(Z:Complex!) #[Extend] {
		Use Complex
		(x y) = (Real(Z) Img(Z))
		Exp = Complex:Polar(y Math:Exp(x))
	}
}
