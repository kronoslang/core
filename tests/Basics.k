"Hello world!"

2 + 5

5 * 10 - 3

1 / 9

Math:Pow(2 16)

a = 5

b = 8

c = 3

a + b * c

a+b*c

two-things = Pair(1 2)

two-things

First(two-things)

Rest(two-things)

Pair(1 Pair(2 3))

(1 2 3)

First(1 2 3)

Rest(1 2 3)


First(Rest(1 2 3 4 5 6))

Rest(Rest(1 2 3 4 5 6))

Add(3 5)

Add(Pair(3 5))

Add(two-things)

my-list = (1 2 3 4 5)

First(my-list)

Rest(my-list)

(x y) = my-list

x

y

Square(x) {
	x * x
}


Square(3)

Square(9)

Distance(x1 y1 x2 y2) {
	dx = x2 - x1
	dy = y2 - y1
	Math:Sqrt( Square(dx) + Square(dy) )
}


Distance(0 0 3 4)

; any symbols bound within the function do not exist outside of it

dx

Algorithm:Map(Square 1 2 3 4 5 6 7 8)

Algorithm:Map(x => x + 100
			  1 2 3 4 5 6 7 8)

Algorithm:Map((+ 100) 1 2 3 4 5 6 7 8)

Algorithm:Map((/ 100) 1 2 3 4 5 6 7 8)

Algorithm:Map((100 /) 1 2 3 4 5 6 7 8)

; binary section

Algorithm:Reduce((+) 1 2 3 4 5 6 7 8)


; or with a lambda

Algorithm:Reduce((a b) => (b a) 1 2 3 4 5 6 7 8)


:Test:Eval-CG+Sf() { Handle("Hello world!" '_ ) }

:Test:Eval-8mcqG() { Handle(2 + 5 '_ ) }

:Test:Eval-VUC4d() { Handle(5 * 10 - 3 '_ ) }

:Test:Eval-gNodA() { Handle(1 / 9 '_ ) }

:Test:Eval-bete-() { Handle(Math:Pow(2 16) '_ ) }

:Test:Eval-S9Zx4() { Handle(a + b * c '_ ) }

:Test:Eval-7FjlE() { Handle(a+b*c '_ ) }

:Test:Eval-VGRHJ() { Handle(two-things '_ ) }

:Test:Eval-T2jHk() { Handle(First(two-things) '_ ) }

:Test:Eval-k9+Sg() { Handle(Rest(two-things) '_ ) }

:Test:Eval-hmlq0() { Handle(Pair(1 Pair(2 3)) '_ ) }

:Test:Eval-aP1Uc() { Handle((1 2 3) '_ ) }

:Test:Eval-lcVCr() { Handle(First(1 2 3) '_ ) }

:Test:Eval-ajtdO() { Handle(Rest(1 2 3) '_ ) }

:Test:Eval-IOzBY() { Handle(First(Rest(1 2 3 4 5 6)) '_ ) }

:Test:Eval-q0nQg() { Handle(Rest(Rest(1 2 3 4 5 6)) '_ ) }

:Test:Eval-0k-4r() { Handle(Add(3 5) '_ ) }

:Test:Eval-GUsl0() { Handle(Add(Pair(3 5)) '_ ) }

:Test:Eval-f9xCK() { Handle(Add(two-things) '_ ) }

:Test:Eval-uMjYo() { Handle(First(my-list) '_ ) }

:Test:Eval-JNE7H() { Handle(Rest(my-list) '_ ) }

:Test:Eval-Bjf6c() { Handle(x '_ ) }

:Test:Eval-K+f6T() { Handle(y '_ ) }

:Test:Eval-HbIWz() { Handle(Square(3) '_ ) }

:Test:Eval-AqyU-() { Handle(Square(9) '_ ) }

:Test:Eval-U5p8S() { Handle(Distance(0 0 3 4) '_ ) }

:Test:Eval-t0VOI() { Handle(dx '_ ) }

:Test:Eval-3iZQm() { Handle(Algorithm:Map(Square 1 2 3 4 5 6 7 8) '_ ) }

:Test:Eval-gLSZu() { Handle(Algorithm:Map(x => x + 100
			  1 2 3 4 5 6 7 8) '_ ) }

:Test:Eval-B-zIK() { Handle(Algorithm:Map((+ 100) 1 2 3 4 5 6 7 8) '_ ) }

:Test:Eval-UMoDX() { Handle(Algorithm:Map((/ 100) 1 2 3 4 5 6 7 8) '_ ) }

:Test:Eval-K9dOH() { Handle(Algorithm:Map((100 /) 1 2 3 4 5 6 7 8) '_ ) }

:Test:Eval-OJ58h() { Handle(Algorithm:Reduce((+) 1 2 3 4 5 6 7 8) '_ ) }

:Test:Eval-sUFsJ() { Handle(Algorithm:Reduce((a b) => (b a) 1 2 3 4 5 6 7 8) '_ ) }
