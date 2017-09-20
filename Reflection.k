;
; Utility functions for type reflection
;
 
True = Not(nil)
Otherwise = True

Invalid-Function() {
	(_ Invalid-Function) = nil
}

First(pair) {
	(First _) = pair
}

Rest(pair) {
	(_ Rest) = pair
}

Pair(fst rst) {
	Pair = (fst rst)
}

Nil?(n) {
	Nil? = Equal-Type(n nil)
}

True?(t) {
	True? = Equal-Type(t True)
}

Pair?(p) {
	Pair? = nil

	(a b) = p
	Pair? = Require((a b) True)
}

Atom?(a) {
	Atom? = Not(Pair?(a))
}

Constant?(a) {
	Constant? = Equal-Type(Class-Of(a) Constant)
}

Real?(a) {
	Real? = Reflection:Is-Any-Of(a Float Double Int32 Int64 Constant)
	Real? = Reflection:Is-Any-Of(First(Vector:Unpack(a)) Float Double Int32 Int64 Constant)
}

Integer?(a) {
	Integer? = Reflection:Is-Any-Of(a Int32 Int64)
	Integer? = When(Equal-Type(Class-Of(a) Constant) & Constant - Floor(Constant) == #0 True)
	Integer? = Recur(First(Vector:Unpack(a)))
}

Floating?(a) {
	Floating? = Reflection:Is-Any-Of(a Float Double Constant)
	Floating? = Recur(First(Vector:Unpack(a)))
}

Bound?(sym) {
	Equal-Type(Class-Of(sym) Class-Of(Recur))
}

Single-Precision?(a) {
	Single-Precision? = Reflection:Is-Any-Of(a Float)
	Single-Precision? = Recur(First(Vector:Unpack(a)))
}

Double-Precision?(a) {
	Double-Precision? = Reflection:Is-Any-Of(a Double)
	Double-Precision? = Recur(First(Vector:Unpack(a)))
}

Vector?(a) {
	Vector? = Require(Vector:Unpack(a) Vector)
}

Class-Of(a) {
	vlst = Vector:Unpack(a)
	Class-Of = (Class-Of(First(vlst)) Arity(vlst))
}

Type-Check(data constraints) {
	Type-Check = Eval(constraints data) : data 
				 Raise(data " is not of type " constraints)
}

Package Reflection {
	Is-Any-Of(data types) {
		cls = Class-Of(data)

		Is-Any-Of = Equal-Type(types cls) : True nil

		(t ts) = types
		Is-Any-Of = Recur(data ts)
		Is-Any-Of = When(Equal-Type(t cls) True)

	}
}