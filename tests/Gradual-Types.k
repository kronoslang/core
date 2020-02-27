; just ignore me while I defeat some sanity checks

Dangerous-Eval(fn args) #[Pattern] {	
	val = Handle(fn(args) { nil })
	When(Not(Nil?(val)) val)
}


; by itself, this seems like a reasonable implementation of fold.

Dangerous-Fold(fn values...) {
	; terminating case when 'values...' can't be split any more
	Dangerous-Fold = values...

	(x xs) = values...
	Dangerous-Fold = Dangerous-Eval(fn x Recur(fn xs))
}


Dangerous-Fold(Add 1 2 3)


Dangerous-Fold(Add 1 2 "foo")


Better-Fold(fn values...) {
	Better-Fold = values...
	(x xs) = values...
	Better-Fold = fn(x Recur(fn xs))
}


Better-Fold(Add 1 2 3)

Better-Fold(Add 1 2 "foo")

Real?(1)


Real?("foo")


Constraints:Real!(1)


Constraints:Real!("foo")

Describe(x) {
	Use Constraints

	Describe = 
		("sequence:" 
			Algorithm:Map(
				Describe Sequence!(x)))

	Describe = ("some number" Real!(x))
	Describe = ("integer" Integer!(x))
	Describe = ("compile-time constant" Constant!(x))
}


Describe(1)

Describe(#42)

Describe(1 2q #3 (#4 5) 6)


foo:Real! = 3

foo


bar:Real! = "not real"

bar

Hypot(a:Real! b:Real!) {
	Math:Sqrt(a * a + b * b)
}


Hypot(3 4)


Hypot(#3 4)


Hypot(3 "FOUR!")


Algorithm:Expand(#10 (+ 1) 1)


Algorithm:Expand(10 (+ 1) 1)

Type Old-Complex


re = 1

im = 1


; manually decorate a pair with a type tag

z = Make(Old-Complex re im)

i = Make(Old-Complex 0 1)


; extend `Mul` for our custom type

Mul(a b) #[Extend] {
	; `Break` pattern matches by default
	(ar ai) = Break(Old-Complex a)
	(br bi) = Break(Old-Complex b)

	Make(Old-Complex 
			ar * br - ai * bi 
			ar * bi + br * ai)
}


z


i


z * i


; declare our type with constrained members

Type New-Complex(Real:Real! Img:Real!)


Mul(a b) #[Extend] {
	; Generated accessors are in :New-Complex
	Use New-Complex
	
	Cons(
		Real(a) * Real(b) - Img(a) * Img(b)
		Real(a) * Img(b)  + Img(a) * Real(b))
}


; constructor argument order mirrors the type declaration

z* = New-Complex:Cons(1 1)

i* = New-Complex:Cons(0 1)


; we get early type checking

New-Complex:Cons("not really" "a number")


; we get constrained accessor functions

New-Complex:Real(z*)

New-Complex:Img("this string has no real or imaginary parts")


; we get automatic reflection and constraints

New-Complex?(z*)

New-Complex?(42)


Constraints:New-Complex!(z*)

Constraints:New-Complex!(1)


z* * i*

Conjugate(x:Real!) {
	x
}


; add alternative forms with #[Extend]

Conjugate(z:New-Complex!) #[Extend] {
	Use New-Complex
	Cons(Real(z) Neg(Img(z)))
}


Conjugate(z*)


Conjugate(5)

Abs(z:New-Complex!) #[Extend] {
	Use New-Complex
	Math:Sqrt(Real(z * Conjugate(z)))
}


Abs(z*)


; because of type constraints, we did not break the pre-existing `Abs`

Abs(-3)



:Test:Eval-YiN91() { Handle(Dangerous-Fold(Add 1 2 3) '_ ) }

:Test:Eval-TePuS() { Handle(Dangerous-Fold(Add 1 2 "foo") '_ ) }

:Test:Eval-KbHRp() { Handle(Better-Fold(Add 1 2 3) '_ ) }

:Test:Eval-o3dhz() { Handle(Better-Fold(Add 1 2 "foo") '_ ) }

:Test:Eval-J9wVT() { Handle(Real?(1) '_ ) }

:Test:Eval-mkq-p() { Handle(Real?("foo") '_ ) }

:Test:Eval-ca1Vm() { Handle(Constraints:Real!(1) '_ ) }

:Test:Eval-JsNt2() { Handle(Constraints:Real!("foo") '_ ) }

:Test:Eval-aP6tY() { Handle(Describe(1) '_ ) }

:Test:Eval-VIJEY() { Handle(Describe(#42) '_ ) }

:Test:Eval-+KId4() { Handle(Describe(1 2q #3 (#4 5) 6) '_ ) }

:Test:Eval-1Is5M() { Handle(foo '_ ) }

:Test:Eval--m2DF() { Handle(bar '_ ) }

:Test:Eval-AmzUn() { Handle(Hypot(3 4) '_ ) }

:Test:Eval-hhnKF() { Handle(Hypot(#3 4) '_ ) }

:Test:Eval-KKga6() { Handle(Hypot(3 "FOUR!") '_ ) }

:Test:Eval-S8zMt() { Handle(Algorithm:Expand(#10 (+ 1) 1) '_ ) }

:Test:Eval-BkKnY() { Handle(Algorithm:Expand(10 (+ 1) 1) '_ ) }

:Test:Eval-bpf6e() { Handle(z '_ ) }

:Test:Eval-6MR6D() { Handle(i '_ ) }

:Test:Eval-cF-q4() { Handle(z * i '_ ) }

:Test:Eval-1QpH0() { Handle(New-Complex:Cons("not really" "a number") '_ ) }

:Test:Eval-UZhmZ() { Handle(New-Complex:Real(z*) '_ ) }

:Test:Eval-BqJHY() { Handle(New-Complex:Img("this string has no real or imaginary parts") '_ ) }

:Test:Eval-yY2-t() { Handle(New-Complex?(z*) '_ ) }

:Test:Eval-lxpoX() { Handle(New-Complex?(42) '_ ) }

:Test:Eval-lKc+R() { Handle(Constraints:New-Complex!(z*) '_ ) }

:Test:Eval-Tg8Sz() { Handle(Constraints:New-Complex!(1) '_ ) }

:Test:Eval-B393x() { Handle(z* * i* '_ ) }

:Test:Eval-s4XXD() { Handle(Conjugate(z*) '_ ) }

:Test:Eval-OShVb() { Handle(Conjugate(5) '_ ) }

:Test:Eval-+Zcjn() { Handle(Abs(z*) '_ ) }

:Test:Eval-bd6VP() { Handle(Abs(-3) '_ ) }
