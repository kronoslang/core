Import Algorithm
Import Math

Package Interpolation {
	BPF(x poly-segs...) {
		i = Algorithm:Upper-Bound-Index((px py) => (px > x) poly-segs...)
		(x0 coefs) = Select(poly-segs... i)
		BPF = Math:Horner-Scheme(x - x0 coefs)
	}

	Lines(points...) {
		((x sv) _) = points...
		(fake mp) = Algorithm:Zip-With( {
				((x1 y1) (x2 y2)) = arg
				[x1 y1 (y2 - y1) / (x2 - x1)]
			} ((x - 1 sv) points...) points...)
		Lines = mp
	}

	Splines(points...) {
		Use Algorithm

		((x sv) _)  = points...
		((xn ev) _) = Take-Last(#1 points...) 
		pad-pts     = Concat(((x - #1 sv) points...) [(xn + #1 ev)])

		Splines = For(Arity(points...) 1i 1i {
			((x0 v0) 
			 (x1 v1) 
			 (x2 v2) 
			 (x3 v3) _) = For(#4 arg - 1i 1i 'Select(pad-pts _))

			m1   = (v2 - v0) / (x2 - x0)
			m2   = (v3 - v1) / (x3 - x1)
			norm = #1 / (x2 - x1)

			(   x1 
			    v1
			    m1 * norm
			    (#-2 * m1 - m2 + #3 * (v2 - v1)) * norm * norm
			    (m1 +  m2 + #2 * (v1 - v2)) * norm * norm * norm
			)
		})
	}

	Linear(h x0 x1) {
		;; Interpolate linearly between x0 an x1 as h ranges from 0 to 1.
		Linear = x0 + h * (x1 - x0)
	}

	Hermite(h xm1 x0 x1 x2) {
		;; Hermite interpolation between 'x0' and 'x1' as 'h' goes from 0 to 1, with further control points 'xm1' and 'x2' referring to past and future points.

		; adapted from musicdsp.org, C source attributed to Laurent De Soras
		c  = (x1 - xm1) * #0.5
		v  = x0 - x1
		w  = c + v
		a  = w + v + (x2 - x0) * #0.5
		bn = w + a 

		Hermite = ((((a * h) - bn) * h + c) * h + x0)
	}

	Hermite-Fn(h fn) {
		Hermite(h fn(-1) fn(0) fn(1) fn(2))
	}

	In(h pts) {
		;; Interpolation considering all of 'pts'. 'h' moves the value between the centermost pair of values in 'pts', with the other points providing additional control points.
		N = Arity(pts)
		fun = N == #4 : Hermite 
		      N == #2 : Linear
		      N == #1 : (h pts) => h
		      Throw:Invalid-Argument("No interpolator for " N " points")

		In = fun(h List-to-Tuple(pts))
	}
}
