Import Exception
Import Reflection

Package Algorithm {
	Brief(documentation) {
		;; Generate algorithmic circuits from data structures.
		nil
	}

	Expand(count:Constant! iterator seed) {
		;; Produces a list of 'count' elements, starting with 'seed' and generating the following elements by applying 'iterator' to the previous one.
		Expand = count  >= #2 : (seed Recur(count - #1 iterator Eval(iterator seed)))
				 count  >= #1 : (seed nil) nil
	}

	Map(func:Function! set...) {
		;; Applies 'func' to each element in 'set', collecting the results in a new structurally similar set.
	 	Map = Nil?(set...) : nil
	 		  Eval(func set...)

	 	(x xs) = set...
	 	Map = (Eval(func x) Recur(func xs))
	}

	Flat-First(x) {
		;; Returns the first element in 'x' regardless of its algebraic structure.
		Flat-First = x
		Flat-First = Recur(First(x))
	}

	Zip-With(func:Function! as bs) {
		;; Applies a binary 'func' to elements pulled from 'as' and 'bs', collecting the results.
		(asf asr) = as
		(bsf bsr) = bs
		Zip-With = When(Nil?(as) | Nil?(bs) nil
						Atom?(as) & Atom?(bs) Eval(func as bs)
						Atom?(as) Eval(func as bsf)
						Atom?(bs) Eval(func asf bs))
		Zip-With = (Eval(func asf bsf) Recur(func asr bsr))
	}

	Zip3-With(func:Function! as bs cs) {
		;; Applies a ternary 'func' to elements pulled from 'as', 'bs' and 'cs', collecting the results.
		(asf asr) = as
		(bsf bsr) = bs
		(csf csr) = cs

		Zip3-With = When(Nil?(as) | Nil?(bs) | Nil?(cs)
							nil
						Otherwise
							Eval(func
									Flat-First(as)
									Flat-First(bs)
									Flat-First(cs)))

		Zip3-With = (Eval(func asf bsf csf) Recur(func asr bsr csr))
	}

	Zip(as bs) {
		;; Produces a list of pairs, with respective elements from 'as' and 'bs'.
		Zip = Zip-With('_ as bs)
	}

	Unzip(set...) {
		;; Produces a pair of lists, by extracting the 'First' and 'Rest' of each element in 'set...'.
		Unzip = When(Every(Pair? set...)
			         (Map(First set...) Map(Rest set...)))
	}

	Reduce(func:Function! set...) {
		;; Applies a binary 'func' to combine the first two elements of a list as long as the list is more than one element long.
	 	(a b) = set...
	 	Reduce = Nil?(b)    : a
	 			 Atom?(set...) : set...
	 			 Eval(func a b)

	 	(x1 x2 xs) = set...
		Reduce = Recur(func Eval(func x1 x2) xs)
	}

	Accumulate(func:Function! set...) {
		;; Produces a list where each element is produced by applying 'func' to the previously produced element and an element from 'set'.
		(a b) = set...
		Accumulate = Nil?(b)		: set...
					 Atom?(set...)	: set...
					 (a Eval(func a b))

		(x1 x2 xs) = set...
		acc = Eval(func x1 x2)

		Accumulate = (x1 Recur(func acc xs))
	}

	Fold(func:Function! set...) {
		;; Folds 'set' by applying 'func' to the first element of 'set' and a recursive fold of the rest of 'set'.
	 	(x xs) = set...

	 	Fold = Atom?(set...) : set...
	 		   Nil?(xs)   : x
	 		   Eval(func x Recur(func xs))
	}

	Filter(predicate:Function! set) {
		;; Evaluates 'predicate' for each element in 'set', removing those elements for which nil is returned.
		Filter = When(Atom?(set)
			Throw:Invalid-Argument("Filter requires a nil-terminated list"))

		(x xs) = set
		Filter = predicate(x) : (x Recur(predicate xs))
								Recur(predicate xs)

		Filter = When(Nil?(set) nil)
	}

	Iterate(n:Constant! func:Function! x) {
		;; Applies a pipeline of 'n' 'func's to 'x'.
		Iterate = n > #0 : Recur(n - #1 func func(x)) x
	}

	Repeat(n:Constant! x) {
		;; Makes a list of 'n' elements that have the value 'x'.
		Expand(n '_  x)
	}

	Count(n:Constant!) {
		;; Makes a list of invariant constants from #1 to n
		Expand(n (+ #1) #1)
	}

	Count(n:Constant! start) #[Extend] {
		;; Makes a list of 'n' elements, counting up from 'start'
		Expand(n (+ #1) start)
	}

	Count(n:Constant! start step) #[Extend] {
		;; Makes a list of 'n' elements, counting up from 'start' in 'step's.
		Expand(n (+ step) start)
	}

	Every(predicate:Function! set...) {
		;; #true if all elements in 'set' are true according to 'predicate'.
		Every = Nil?(set...) : True 
				predicate(set...)

		(x xs) = set...
		Every = predicate(x) : Recur(predicate xs) nil
	}

	Some(predicate:Function! set...) {
		;; #true if some element in 'set' is true according to 'predicate'.
		Some = predicate(set...) : set... nil

		(x xs) = set...
		Some = Nil?(set...) 			: nil
			   Not(predicate(x)) 		: Recur(predicate xs)
			   x
	}

	Reverse(set...) {
		Reverse = Reduce((a b) => (b a) nil set...)
	}

	Multi-Map(func:Function! sets...) {
		;; Applies a polyadic 'func' to a tuple of corresponding elements in all of the 'sets'. The resulting set length corresponds to the smallest input set.
		Multi-Map = Some(Nil? sets...)   : nil
			   		Every(Pair? sets...) : (Eval(func Map(First sets...))
									   		Recur(func Map(Rest sets...)))
			   		Eval(func Map(Flat-First sets...))
	}

	Concat(as bs) {
		;; Prepends the list 'as' to the list 'bs'
		Concat = Atom?(as) : (as bs) Throw:Unexpected("Concatenation failed")
		Concat = Nil?(as)  : bs (First(as) Recur(Rest(as) bs))
	}

	Flatten(set...) {
		;; Flatten any nested data structures, resulting in a flat list.
		(x xs) = set...
		Flatten = set...
		Flatten = Nil?(set...) : nil
				  Concat(Recur(x) Recur(xs))

	}

	Choose(truth when-true when-false) {
		;; Choose either 'when-true' or 'when-false' based on 'truth'.
		;; The branches should have equal type.

		; compile time choose as fallback
		Choose = When(truth when-true
					  Not(truth) when-false)

		; choose for atoms
		Choose = Ternary-Select(truth when-true when-false)

		; choose between algebraic components
		(wt wts) = when-true
		(wf wfs) = when-false
		Choose = (Choose(truth wt wf) Choose(truth wts wfs))

		; choose for identical custom types
		tid = Class-of(when-true)
		Choose = When(when-true ==t when-false
					  Make(tid Choose(
					  	truth Break(tid when-true) Break(tid when-false))))
	}

	Binary-Converge(pred:Function! lo hi sorted-set...) {
		i = (lo + hi) / #2
		t = pred(Select(sorted-set... i))
		Binary-Converge = (
			Ternary-Select(t lo i)
			Ternary-Select(t i hi)
			)
	}

	Skip(N:Constant! set...) {
		;; Remove `N` items from the beginning of `set...`
		Skip = N == #0 : set... nil
		(x xs) = set...
		Skip = N >= #1 : Recur(N - #1 xs) set...
	}

	Take(N:Constant! set...) {
		;; Take the first `N` items from the beginning of `set...`.
		Take = (Nil?(set...) | N < #1) : nil [set...]
		(x xs) = set...
		Take = N >= #1 : (x Recur(N - #1 xs)) nil
	}

	Take-Last(N:Constant! xs) {
		;; Take the last `N` items from the beginning of `set...`.
		Take-Last = Skip(Arity(xs) - N xs)
	}

	Split(xs...) {
		;; Splits the list `xs...` in half
		Nh = Arity(xs...) / #2
		(Take(Nh xs...) Skip(Nh xs...))
	}

	Upper-Bound-Index(pred:Function! sorted-set...) {
		N  = Arity(sorted-set...)
		Ns = Ceil(Math:Log(N) / Math:Log(#2))

		Lower-Bound-Index = Throw:Invalid-Argument("Couldn't perform binary search")

		Upper-Bound-Index = First(Iterate(Ns (lo hi) => Binary-Converge(pred lo hi sorted-set...)
								         0i Coerce(Int32 N)))
	}

	Find-Max-With(pred:Function! set...) {
		;; Returns the index to the element in `set...` that is
		;; the greatest according to a binary `pred`icate.

		iter(pred I mv mi set) {
			iter = (mi mv)

			(x xs) = set
			new-max? = pred(x mv)

			iter =
				Recur(
					pred
					I + #1
					Choose(new-max? x mv)
					Choose(new-max? I mi) xs)

			iter = When(Nil?(xs) (mi mv))
		}

		(h t) = set...
		iter(pred 1i h 0i t)
	}

	Find-Max(set...) {
		;; Returns the index to the element in `set...` that has
		;; the greatest value. Returns the pair `(index value)`.
		Find-Max-With((>) set...)
	}

	Find-Min(set...) {
		;; Returns the index to the element in `set...` that has
		;; the least value. Returns the pair `(index min-value)`.
		Find-Max-With((<) set...)
	}

	Partition(N:Constant! set...) {
		;; Partition `set...` into tuples with `N` elements each.
		front = Take(N set...)
		When(
			Not(front ==t set...)
				(front Recur(N Skip(N set...)))
			Nil?(set...)
				nil
			Otherwise
				(set... nil))
	}
}

Nth(index set...) {
	;; Takes the 'index'th element of 'set'.
	skip = Algorithm:Iterate(index Rest set...)
	Nth = Pair?(skip) : First(skip) skip
}

Sum(numbers...) {
	;; Compute the sum of `numbers...`.
	Sum = Algorithm:Reduce(Add numbers...)
}

Average(numbers...) {
	;; Compute the average of `numbers...` 
	Sum(numbers...) * (#1 / Arity(numbers...))
}

Product(numbers...) {
	;; Compute the product of `numbers...`.
	Product = Algorithm:Reduce(Mul numbers...)
}