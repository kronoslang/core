Sum-All(set...) {
	; fallback form
	Sum-All = set...

	; while multiple elements are bound to set, destructure
	; and recur.
	(x xs) = set...
	Sum-All = x + Sum-All(xs)
}


Sum-All(1)


Sum-All(1 2 3)

Sum-All(1 "two")

F!(n) {
	When(n > #1
			n * F!(n - #1)
		 Otherwise
		 	#1)
}


; generate a compile time tuple of numbers 1..20

xs = Algorithm:Expand(#20 (+ #1) #1)

xs


; compute compile time factorials

Algorithm:Map(F! xs)


F!(n) #[Extend] {
	When(
		Not(Constant?(n))
		Raise("I can only compute factorials of compile time constants."))
}


F!(10)


F!("foo")


; does not trigger for invariants.

F!(#10)


is = Algorithm:Expand(#5 (+ 1) 1)

is

Sum-All(is)


; This is because of the terminating condition

Sum-All(nil)

Sum-All(set...) #[Extend] {
	When(Nil?(set...) #0)
}


Sum-All(nil)


; revisit the motivating case

Sum-All(is)


; we can now reduce lists

Sum-All([100 1])


; or using shorthand

Sum-All[100 1]


; because `#0` will implicitly coerce to all runtime types, the type

; of the reduction is preserved

Class-Of(Sum-All[1d 2d 3d])


:Test:Eval-oYhH+() { Handle(Sum-All(1) '_ ) }

:Test:Eval-C7Ddu() { Handle(Sum-All(1 2 3) '_ ) }

:Test:Eval-aCNp7() { Handle(Sum-All(1 "two") '_ ) }

:Test:Eval-v19TL() { Handle(xs '_ ) }

:Test:Eval-i1Wom() { Handle(Algorithm:Map(F! xs) '_ ) }

:Test:Eval-HpBtj() { Handle(F!(10) '_ ) }

:Test:Eval-7zxbp() { Handle(F!("foo") '_ ) }

:Test:Eval-Jz1ZT() { Handle(F!(#10) '_ ) }

:Test:Eval-tMIIb() { Handle(is '_ ) }

:Test:Eval-1MQVO() { Handle(Sum-All(is) '_ ) }

:Test:Eval-udMAj() { Handle(Sum-All(nil) '_ ) }

:Test:Eval-udMAj-1() { Handle(Sum-All(nil) '_ ) }

:Test:Eval-1MQVO-1() { Handle(Sum-All(is) '_ ) }

:Test:Eval-SP+wd() { Handle(Sum-All([100 1]) '_ ) }

:Test:Eval-vcrTt() { Handle(Sum-All[100 1] '_ ) }

:Test:Eval-irBvn() { Handle(Class-Of(Sum-All[1d 2d 3d]) '_ ) }

Square-Number(x) {
	x * x
}


Square-Number(3)


; Unfortunately,

Square-Number("horse")


Square(x) {
	Square = x * x

	Square = String:Append("[" String:Append(x "]"))

	; For a pair, let's square both elements
	(a b) = x
	Square = (Square(a) Square(b))
}


Square(3)


Square("horse")


Square(10 9)


; Our definition of 'square of pairs' has some serendipitous

; consequences

Square(1 2 3 4 5)


Square((1 2) (3 4 "foo") 5 6)

MyFold(f set...) {
	; if the set can't be destructured, assume it's a scalar
	MyFold = set...

	; pattern match against a destructurable set
	(x xs) = set...
	MyFold = f(x MyFold(f xs))
}


MyFold(Add 1 2 3 4 5)

MyFold(Add [1 2 3])

; append a form after the fact with #[Extend]

MyFold(f set...) #[Extend] {
	(x xs) = set...
	When(Nil?(xs) x)
}


MyFold(Mul [1 2 3])

MyMap(f set...) {
	; map trailing scalar
	MyMap = f(set...)

	; always map terminating nil to nil
	MyMap = When(Nil?(set...) nil)

	; destructure, map head and recur on tail
	(x xs) = set...
	MyMap = (f(x) MyMap(f xs))
}


MyMap((* 100) 7 3 2 1)

MyMap(Math:Sqrt [1 2 3 4 5 6])

Import Gen


vibr = Gen:Sin(5) * 0.01 + 1

freqs = MyMap((* vibr) 220 275 330)

oscs  = MyMap(Gen:Tri freqs)


:Test:Audio-dmMcq() { snd = MyFold((+) oscs) * 0.1 snd }

:Test:Eval-7VQ5u() { Handle(Square-Number(3) '_ ) }

:Test:Eval-k7AkV() { Handle(Square-Number("horse") '_ ) }

:Test:Eval-HbIWz() { Handle(Square(3) '_ ) }

:Test:Eval-2T19k() { Handle(Square("horse") '_ ) }

:Test:Eval-g4Nzi() { Handle(Square(10 9) '_ ) }

:Test:Eval-hiwJR() { Handle(Square(1 2 3 4 5) '_ ) }

:Test:Eval-NzkLI() { Handle(Square((1 2) (3 4 "foo") 5 6) '_ ) }

:Test:Eval-ATAd0() { Handle(MyFold(Add 1 2 3 4 5) '_ ) }

:Test:Eval-HT4ja() { Handle(MyFold(Add [1 2 3]) '_ ) }

:Test:Eval-ammfJ() { Handle(MyFold(Mul [1 2 3]) '_ ) }

:Test:Eval-vmbyK() { Handle(MyMap((* 100) 7 3 2 1) '_ ) }

:Test:Eval-Npds0() { Handle(MyMap(Math:Sqrt [1 2 3 4 5 6]) '_ ) }

