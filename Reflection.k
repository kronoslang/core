;
; Utility functions for type reflection
;

True = Not(nil)
Otherwise = True

Invalid-Function() #[Pattern] {
	(_ Invalid-Function) = nil
}

First(pair) #[Pattern] {
	;; Destructure 'pair' and return the first half.
	(First _) = pair
}

Rest(pair) #[Pattern] {
	;; Destructure 'pair' and return the second half.
	(_ Rest) = pair
}

Pair(fst rst) {
	;; Incorporate 'fst' and 'rst' as the first and second halves of a pair.
	Pair = (fst rst)
}

Sequence(head tail...) {
	;; construct a sequence with 'head' followed by the data in 'tail...'
	(head tail...)
}

Nil?(n) {
	Nil? = Equal-Type(n nil)
}

Constraints:Nil!(n) #[Pattern] {
	;; Matches when 'n' is nil
	When(Nil?(n) n)
}

True?(t) {
	True? = Equal-Type(t True)
}

Constraints:True!(t) #[Pattern] {
	;; Matches when 'n' is true
	When(True?(t) t)
}

Pair?(p) {
	Pair? = nil

	(a b) = p
	Pair? = Require((a b) True)
}

Constraints:Sequence!(p) #[Pattern] {
	;; Matches when 'p' can be destructured.
	When(Pair?(p) p)
}

Constraints:Seq-Length!(s n) #[Pattern] {
	;; Matches when 's' is a sequence of at least 'n' elements
	When(Arity(s) >= n s)
}

Atom?(a) {
	Atom? = Not(Pair?(a))
}

Constraints:Atom!(a) #[Pattern] {
	;; Matches when 'a' is an atom, a value that can not be further destructured.
	When(Atom?(a) a)
}

Constant?(a) {
	Constant? = Equal-Type(Class-of(a) Constant)
}

Constraints:Constant!(a) #[Pattern] {
	;; Matches when 'a' is an invariant constant.
	When(Constant?(a) a)
}

Constraints:Condition!(v pred) #[Pattern] {
	;; Tests 'v'alue using 'pred'icate. If pred(v) is True, returns 'v', otherwise do not match.
	When(pred(v) v)
}

Scalar?(a) {
	Scalar? = Reflection:Is-Any-Of(a Float Double Int32 Int64 Constant)
	Scalar? = Reflection:Is-Any-Of(First(Vector:Unpack(a)) Float Double Int32 Int64 Constant)
}

Constraints:Scalar!(s) #[Pattern] {
	;; Matches when 's' is a scalar numeric value.
	When(Scalar?(s) s)
}

Integer?(a) {
	Integer? = Reflection:Is-Any-Of(a Int32 Int64)
	Integer? = When(Equal-Type(Class-of(a) Constant) When(Constant - Floor(Constant) == #0) True)
	Integer? = Recur(First(Vector:Unpack(a)))
}

Constraints:Integer!(i) #[Pattern] {
	;; Matches when 'i' is a scalar integer
	When(Integer?(i) i)
}

Real?(a) {
	Real? = Reflection:Is-Any-Of(a Float Double Constant)
	Real? = Recur(First(Vector:Unpack(a)))
}

Constraints:Real!(r) #[Pattern] {
	;; Matches when 'r' is a scalar real number
	When(Real?(r) r)
}

Bound?(sym) {
	Equal-Type(Class-of(sym) Class-of(Recur))
}

Single-Precision?(a) {
	Single-Precision? = Reflection:Is-Any-Of(a Float)
	Single-Precision? = Recur(First(Vector:Unpack(a)))
}

Constraints:Single-Precision!(sp) #[Pattern] {
	;; Matches when 'sp' is a single precision floating point number
	When(Single-Precision?(sp) sp)
}

Double-Precision?(a) {
	Double-Precision? = Reflection:Is-Any-Of(a Double)
	Double-Precision? = Recur(First(Vector:Unpack(a)))
}

Constraints:Double-Precision!(dp) #[Pattern] {
	;; Matches when 'dp' is a double precision floating point number
	When(Double-Precision(dp) dp)
}

Function?(fn) {
	t = Class-of( { nil } )

	Function? = nil

	Function? = When(t ==t Class-of(fn) True)

	(f r) = fn
	Function? = And(Function?(f) Function(r))
}

Vectorize-Type?(t) {
	nil
}

Constraints:Function!(fn) {
	;; Matches when 'fn' is callable
	When(Function?(fn) fn)
}


Class-of(a) #[Extend] {
	vlst = Vector:Unpack(a)
	Class-of = Require(vlst Class-of(First(vlst)) Arity(vlst))
}

Class-Of = Class-of

Type-Check(data constraints) {
	Type-Check = Eval(constraints data) : data
				 Raise(data " is not of type " constraints)
}

Package Reflection {
	Is-Any-Of(data types) {
		cls = Class-of(data)

		Is-Any-Of = Equal-Type(types cls) : True nil

		(t ts) = types
		Is-Any-Of = Recur(data ts)
		Is-Any-Of = When(Equal-Type(t cls) True)

	}

	Tuple-of-Type?(type tuple) {
		Tuple-of-Type? = Class-of(tuple) ==t type

		(e es) = tuple
		Tuple-of-Type? = (Class-of(e) ==t type) & Recur(type es)
	}
}

Homogeneous?(tuple) {
	Homogeneous? = True

	(e es) = tuple
	Homogeneous? = Reflection:Reflection:Tuple-of-Type?(Class-of(e) es)
}
