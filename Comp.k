Compose(fn-list...) {
	;; Composes functions in a nil-terminated 'fn-list' into a chain, which passes the initial argument through the entire chain.
	comp(x fns) {
		(f fs) = fns
		comp = fns(x)
		comp = Nil?(fns) : f(x)
			   Recur(f(x) fs)
	}
	'comp(_ fn-list...)
}

Juxtapose(fn-list...) {
	;; Composes a function that passes its argument to all functions in the nil-terminated 'fn-list', returning the results in a list.

	juxt(x fns) {
		(f fs) = fns
		juxt = fns(x)
		juxt = Nil?(fns) : nil
			(f(x) Recur(x fs))
	}

	'juxt(_ fn-list...)
}