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

Constraints:Nil!(n) {
	;; Matches when 'n' is nil
	When(Nil?(n) n)
}

True?(t) {
	True? = Equal-Type(t True)
}

Constraints:True!(t) {
	;; Matches when 'n' is true
	When(True?(t) t)
}

Pair?(p) {
	Pair? = nil

	(a b) = p
	Pair? = Require((a b) True)
}

Constraints:Sequence!(p) {
	;; Matches when 'p' can be destructured.
	When(Pair?(p) p)
}

Atom?(a) {
	Atom? = Not(Pair?(a))
}

Constraints:Atom!(a) {
	;; Matches when 'a' is an atom, a value that can not be further destructured.
	When(Atom?(a) a)
}

Constant?(a) {
	Constant? = Equal-Type(Class-Of(a) Constant)
}

Constraints:Constant!(a) {
	;; Matches when 'a' is an invariant constant.
	When(Constant?(a) a)
}

Constraints:Condition!(v pred) {
	;; Tests 'v'alue using 'pred'icate. If pred(v) is True, returns 'v', otherwise do not match.
	When(pred(v) v)
}

Scalar?(a) {
	Scalar? = Reflection:Is-Any-Of(a Float Double Int32 Int64 Constant)
	Scalar? = Reflection:Is-Any-Of(First(Vector:Unpack(a)) Float Double Int32 Int64 Constant)
}

Constraints:Scalar!(s) {
	;; Matches when 's' is a scalar numeric value.
	When(Scalar?(s) s)
}

Integer?(a) {
	Integer? = Reflection:Is-Any-Of(a Int32 Int64)
	Integer? = When(Equal-Type(Class-Of(a) Constant) & Constant - Floor(Constant) == #0 True)
	Integer? = Recur(First(Vector:Unpack(a)))
}

Constraints:Integer!(i) {
	;; Matches when 'i' is a scalar integer 
	When(Integer?(i) i)
}

Real?(a) {
	Real? = Reflection:Is-Any-Of(a Float Double Constant)
	Real? = Recur(First(Vector:Unpack(a)))
}

Constraints:Real!(r) {
	;; Matches when 'r' is a scalar real number
	When(Real?(r) r)
}

Bound?(sym) {
	Equal-Type(Class-Of(sym) Class-Of(Recur))
}

Single-Precision?(a) {
	Single-Precision? = Reflection:Is-Any-Of(a Float)
	Single-Precision? = Recur(First(Vector:Unpack(a)))
}

Constraints:Single-Precision!(sp) {
	;; Matches when 'sp' is a single precision floating point number
	When(Single-Precision?(sp) sp)
}

Double-Precision?(a) {
	Double-Precision? = Reflection:Is-Any-Of(a Double)
	Double-Precision? = Recur(First(Vector:Unpack(a)))
}

Constraints:Double-Precision!(dp) {
	;; Matches when 'dp' is a double precision floating point number
	When(Double-Precision(dp) dp)
}

Vector?(a) {
	Vector? = Require(Vector:Unpack(a) Vector)
}

Constraints:Vector!(v) {
	;; Matches when 'v' is a vector of scalars
	When(Vector?(v) v)
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