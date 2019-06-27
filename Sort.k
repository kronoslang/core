Import Algorithm

Package Bitonic {
	Merge-Stage(set pred up) {
		Use Algorithm

		pow-of-2-below(N limit) {
			N2 = N + N
			N2 < limit : Recur(N2 limit), N
		}

		cmpp(a b) {
			r = pred(a b)
			up : Choose(r (a b) (b a)),
				 Choose(r (b a) (a b))
		}

		N = Arity(set)
		M = pow-of-2-below(#1 N)

		limit = N - M

		front = Take(limit set)
		back  = Take(limit Skip(M set))

		(ordf ordr) = Unzip(Zip-With(cmpp front back))

		unord = Take(M - limit Skip(limit set))

		sset =
			Reduce(Concat
				    ordf
					unord
					ordr)

		Arity(set) < #2 : set,
			Concat(
				Recur(Take(M sset) pred up)
				Recur(Skip(M sset) pred up))
	}

	Sort-Stage(pred up set) {
		Use Algorithm

		(front back) = Split(set)

		Arity(set) < #2 : set
			Merge-Stage(
				Concat(
					Sort-Stage(pred Not(up) front)
					Sort-Stage(pred up back)) pred up)


	}

	Sort-With(pred set...) {
		;; Construct a bitonic sorting network whose output is the `set...`
		;; ordered according to `pred`icate. For example, ascending order is produced by
		;; `(<)` and descending by `(>)`.
		Sort-Stage(pred True set...)
	}

	Sort(set...) {
		;; Construct a bitonic sorting network whose output is the `set...`
		;; ordered in ascending natural order
		Sort-Stage(:Less True set...)
	}
}