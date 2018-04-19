Import Algorithm
Import Implicit-Coerce

Package Test {
	Implicit-Coercion-Matrix() {
		AtomicTypes = [Constant Float Int32 Double Int64]
		Implicit-Coercion-Matrix =
			Algorithm:Map(op => 
				Algorithm:Map(t1 =>
					Algorithm:Map(t2 =>
						op(Coerce(t1 #9) Coerce(t2 #11))
						AtomicTypes) AtomicTypes)
				[Add Sub Mul Div])
	}

	Custom-Implicit-Coerce() {
		Custom-Implicit-Coerce = [
			Fraction:Cons(1i 2i) * 3
			Fraction:Cons(3q 5q) * 4
			Fraction:Cons(2 7) * 9d ]
	}

	Vector-Coerce() {
		Vector-Coerce = [
			#1 + Vector:Pack(10 100 1000 10000)
			#2 + Vector:Pack(20d 200d 2000d 20000d)
			#3 + Vector:Pack(30q 300q 3000q 30000q)
			#4 + Vector:Pack(40i 400i 4000i 40000i)
			]
	}
}

Type Fractional
Package Fraction {
	Cons(num den) {
		Cons = Make(Fractional num den)
	}

	Numerator/Denominator(fraction) {
		(Numerator Denominator) = Break(Fractional fraction)
	}
}

Implicit-Converters(data) {
	type = Class-Of(data)
	Implicit-Converters = When(
		Equal-Type(type Fraction) | Equal-Type(data Fraction)
			[f => Fraction:Numerator(f) * 1 / Fraction:Denominator(f)])
}

Main = Test:Vector-Coerce()
