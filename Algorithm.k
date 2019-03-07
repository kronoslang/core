Import Exception
Import Reflection

Package Algorithm {
	Brief(documentation) {
		;; Higher order functions for applying transformations over data structures.
		nil
	}

	Expand(count iterator seed) {
		;; Produces a list of 'count' elements, starting with 'seed' and generating the following elements by applying 'iterator' to the previous one.
		Expand = count  >= #2 : (seed Recur(count - #1 iterator Eval(iterator seed)))
				 count  >= #1 : (seed nil) nil
	}

	Map(func set...) {
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

	Zip-With(func as bs) {
		;; Applies a binary 'func' to elements pulled from 'as' and 'bs', collecting the results.
		Zip-With = Throw:Invalid-Argument("Can't zip")
		(asf asr) = as
		(bsf bsr) = bs
		Zip-With = When(Nil?(as) | Nil?(bs) nil
						Atom?(as) & Atom?(bs) Eval(func as bs)
						Atom?(as) Eval(func as bsf)
						Atom?(bs) Eval(func asf bs))
		Zip-With = (Eval(func asf bsf) Recur(func asr bsr))
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

	Reduce(func set...) {
		;; Applies a binary 'func' to combine the first two elements of a list as long as the list is more than one element long.
	 	(a b) = set...
	 	Reduce = Nil?(b)    : a
	 			 Atom?(set...) : set...
	 			 Eval(func a b)

	 	(x1 x2 xs) = set...
		Reduce = Recur(func Eval(func x1 x2) xs)
	}

	Accumulate(func set...) {
		;; Produces a list where each element is produced by applying 'func' to the previously produced element and an element from 'set'.
		(a b) = set...
		Accumulate = Nil?(b)		: set...
					 Atom?(set...)	: set...
					 (a Eval(func a b))

		(x1 x2 xs) = set...
		acc = Eval(func x1 x2)

		Accumulate = (x1 Recur(func acc xs))
	}

	Fold(func set...) {
		;; Folds 'set' by applying 'func' to the first element of 'set' and a recursive fold of the rest of 'set'.
	 	(x xs) = set...

	 	Fold = Atom?(set...) : set...
	 		   Nil?(xs)   : x
	 		   Eval(func x Recur(func xs))
	}

	Filter(predicate set) {
		;; Evaluates 'predicate' for each element in 'set', removing those elements for which nil is returned.
		Filter = When(Atom?(set)
			Throw:Invalid-Argument("Filter requires a nil-terminated list"))

		(x xs) = set
		Filter = predicate(x) : (x Recur(predicate xs))
								Recur(predicate xs)

		Filter = When(Nil?(set) nil)
	}

	Iterate(n func x) {
		;; Applies a pipeline of 'n' 'func's to 'x'.
		Iterate = n > #0 : Recur(n - #1 func func(x)) x
	}

	Every(predicate set...) {
		;; #true if all elements in 'set' are true according to 'predicate'.
		Every = Nil?(set...) : True predicate(set...)

		(x xs) = set...
		Every = predicate(x) : Recur(predicate xs) nil
	}

	Some(predicate set...) {
		;; #true if some element in 'set' is true according to 'predicate'.
		Some = When(predicate(set...) set... nil)

		(x xs) = set...
		Some = Nil?(set...) 			: nil
			   Not(predicate(x)) 		: Recur(predicate xs)
			   x
	}

	Reverse(set...) {
		Reverse = Reduce((a b) => (b a) nil set...)
	}

	Multi-Map(func sets...) {
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
		; choose for atoms
		Choose = Ternary-Select(truth when-true when-false)

		; choose between algebraic components
		(wt wts) = when-true
		(wf wfs) = when-false
		Choose = (Choose(truth wt wf) Choose(truth wts wfs))

		; choose for custom types
		tid = Class-Of(when-true)
		Choose = When(Equal-Type(when-true when-false)
					  Make(tid Choose(
					  	truth Break(tid when-true) Break(tid when-false))))
	}

	Binary-Converge(pred lo hi sorted-set...) {
		i = (lo + hi) / #2
		t = pred(Select(sorted-set... i))
		Binary-Converge = (
			Ternary-Select(t lo i)
			Ternary-Select(t i hi)
			)
	}

	Skip(N xs) {
		Skip = Iterate(N Rest xs)
	}

	Take(N set...) {
		(x xs) = set...
		Take = N > #0 : (x Recur(N - #1 xs)) nil
	}

	Take-Last(N xs) {
		Take-Last = Skip(Arity(xs) - N xs)
	}

	Upper-Bound-Index(pred sorted-set...) {
		N  = Arity(sorted-set...)
		Ns = Ceil(Math:Log(N) / Math:Log(#2))

		Lower-Bound-Index = Throw:Invalid-Argument("Couldn't perform binary search")

		Upper-Bound-Index = First(Iterate(Ns (lo hi) => Binary-Converge(pred lo hi sorted-set...)
								         0i Coerce(Int32 N)))
	}
}

Nth(index set...) {
	;; Takes the 'index'th element of 'set'.
	skip = Algorithm:Iterate(index Rest set...)
	Nth = Pair?(skip) : First(skip) skip
}

Sum(numbers...) {
	Sum = Algorithm:Reduce(Add numbers...)
}

Product(numbers...) {
	Product = Algorithm:Reduce(Mul numbers...)
}