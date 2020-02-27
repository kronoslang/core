My-Number = 3


My-Function = x => x * 10

Test = x => x + 5

Test2(x) {
	Test2 = x + 5
}

Test3(x) {
	x + 5
}

My-Fold(func data) {
	My-Fold = data

	(x xs) = data
	My-Fold = func(x My-Fold(func xs))
}


My-Fold(Add 1 2 3 4 5)

(1 2 3 4)


Pair(1 Pair(2 Pair(3 4)))


my-tuple = (1 2 3 4 5)

(b1 b2 b3 bs) = my-tuple

First(my-tuple)

b1

First(Rest(my-tuple))

b2

First(Rest(Rest(my-tuple)))

b3

Rest(Rest(Rest(my-tuple)))

bs

(1 2 3 4 nil)

[1 2 3 4]

((1 2) (10 20) (100 200))

((1 2) (10 20) 100 200)

; these are confusingly equivalent

[(1 2) (10 20) (100 200)]

[(1 2) (10 20) 100 200]

; these are not equivalent

add-ten = x => x + 10

add-ten(5)


:Test:Eval-vZEHb() { Handle(My-Fold(Add 1 2 3 4 5) '_ ) }

:Test:Eval-Aqnmh() { Handle((1 2 3 4) '_ ) }

:Test:Eval-4dlA1() { Handle(Pair(1 Pair(2 Pair(3 4))) '_ ) }

:Test:Eval-ydB-G() { Handle(First(my-tuple) '_ ) }

:Test:Eval-ZbFMN() { Handle(b1 '_ ) }

:Test:Eval-RAzwm() { Handle(First(Rest(my-tuple)) '_ ) }

:Test:Eval-oNFMK() { Handle(b2 '_ ) }

:Test:Eval-6sVHL() { Handle(First(Rest(Rest(my-tuple))) '_ ) }

:Test:Eval-XBFML() { Handle(b3 '_ ) }

:Test:Eval-jweuD() { Handle(Rest(Rest(Rest(my-tuple))) '_ ) }

:Test:Eval-XEAML() { Handle(bs '_ ) }

:Test:Eval-sKp2A() { Handle((1 2 3 4 nil) '_ ) }

:Test:Eval-FwSoD() { Handle([1 2 3 4] '_ ) }

:Test:Eval-ZyK4L() { Handle(((1 2) (10 20) (100 200)) '_ ) }

:Test:Eval-EgzJW() { Handle(((1 2) (10 20) 100 200) '_ ) }

:Test:Eval-MX58O() { Handle([(1 2) (10 20) (100 200)] '_ ) }

:Test:Eval-B2U5b() { Handle([(1 2) (10 20) 100 200] '_ ) }

:Test:Eval-KOwb9() { Handle(add-ten(5) '_ ) }
