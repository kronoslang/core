Numerals =
   [("M"   #1000)
	("CM"  #900)
	("D"   #500)
	("CD"  #400)
	("C"   #100)
	("XC"  #90)
	("L"   #50)
	("XL"  #40)
	("X"   #10)
	("V"   #5)
	("IV"  #4)
	("I"   #1)]


To-Roman(value) {
	; Compile-time loop using an inner function
	; that recurs.
	encode(value decimals) {
		; examine the head of current list of encodable
		; numerals
		((r d) next) = decimals

		When(; already encoded all numerals?
			 value == #0
				""
			 ; is largest encodable numeral applicable?
			 value >= d
			 	; if so, output it and append the rest.
			 	String:Append(r Recur(value - d decimals))
			 ; skip this numeral and try the next one
			 Otherwise
			 	Recur(value next))
	}

	encode(value Numerals)
}


From-Roman(numeral) #[Pattern] {
	Use Algorithm
	; a loop
 	decode(value previous numeral-chars) {
		; split list of numerals into head and tail
		(vn rn) = numeral-chars
		; find a matching numeral. '==t' checks for compile time
		; type equality.
		num = Some((nn _) => (nn ==t vn) Numerals)
		; Extract the increment
		(_ inc) = num

		When(; all numerals decoded?
			Nil?(numeral-chars)
				value
			; not a valid numeral?
			Nil?(num)
				nil
			; is current numeral smaller than previous?
			inc < previous
			 	; then substract and decode the rest
				Recur(value - inc inc rn)
			Otherwise
			 	; otherwise add and decode the rest
			 	Recur(value + inc inc rn))
	}

	; split string into characters in reverse
	len = String:Length(numeral)
	chars = Map(i => String:Take(String:Skip(numeral i) #1)
				Expand(len (- #1) len - #1))

	; check that we got a valid numeral
	result = decode(#0 #0 chars)
	When(Constant?(result) result)
}


test = Algorithm:Expand(#11 (* #2) #1)

numerals = Algorithm:Map(To-Roman test)

decoded = Algorithm:Map(From-Roman numerals)

test

numerals

decoded

; the Extend attribute allows us to append a polymorphic form to Add

Add(a b) #[Extend] {
	ar = From-Roman(a)
	br = From-Roman(b)
	To-Roman(ar + br)
}


"XIV" + "VIII"


; make sure that non-numeral strings don't match with From-Roman

"foo" + "bar"

Fallback:Binary-Op(func name a b) #[Extend] {
	ar = From-Roman(a)
	br = From-Roman(b)
	To-Roman(func(ar br))
}


"XIV" * "V"


Math:Pow("II" "VIII")


:Test:Eval-vPmfH() { Handle(test '_ ) }

:Test:Eval-f697f() { Handle(numerals '_ ) }

:Test:Eval-nXL3k() { Handle(decoded '_ ) }

:Test:Eval-6o3vJ() { Handle("XIV" + "VIII" '_ ) }

:Test:Eval-x-Jrw() { Handle("foo" + "bar" '_ ) }

:Test:Eval-TbEss() { Handle("XIV" * "V" '_ ) }

:Test:Eval-w3zS1() { Handle(Math:Pow("II" "VIII") '_ ) }
