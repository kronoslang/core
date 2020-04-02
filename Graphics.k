Package g {
	Type pq
	Type pl
	Type pc
	Type pa
	Type ss
	Type sf
	Type tr
	Type ts
	Type tt
	Type vp
}

Package Graphics {
	Use g
	Brief() {
		;; Graphics primitives and composition operations
		nil
	}

	Seq(shapes) {
		Make(pq shapes)
	}

	PolyLine(x1 y1 x2 y2 more...) {
		;; Draw connected line segments between 2 or more sets of coordinates
		Make(pl arg)
	}

	Line(x1 y1 x2 y2) {
		;; Draw a line from (x1,y1) to (x2,y2)
		PolyLine(x1 y1 x2 y2)
	}

	Circle(x y r) {
		;; Draw a circle with a center point at (x,y) and a 'r'adius.
		Make(pc x y r)
	}

	Area-Plot(x y w values) {
		Make(pa x y w values)
	}

	Stroke(color shapes) {
		;; Draw 'shapes...' with 'color', which is a tuple of either (RED GREEN BLUE) or (RED GREEN BLUE ALPHA) with values from 0 to 1.
		Make(ss color shapes)
	}

	Fill(color shapes) {
		;; Fill 'shapes...' with 'color', which is a tuple of either (RED GREEN BLUE) or (RED GREEN BLUE ALPHA) with values from 0 to 1.
		Make(sf color shapes)
	}

	Rotate(angle shapes) {
		;; Rotate 'shapes' by 'angle' degrees
		Make(tr angle shapes)
	}

	Scale(x y shapes) {
		;; Scale 'shapes' by multipliers 'x' and 'y'
		Make(ts (x y) shapes)
	}

	Translate(x y shapes) {
		;; Move all of 'shapes' along the 'x' and 'y' axes
		Make(tt (x y) shapes)
	}

	Canvas(id shapes) {
		VM:Make-Op["kvm_gfx!"
			"const char*" id
			"const char*" String:Interop-Format-JSON(shapes)
			"const void*" [shapes]]
	}

	Viewport(width height shapes) {
		;; Draw 'shapes' in a viewport with coordinate space (0,0) -- (width, height)
		Make(vp (width height) shapes)
	}
}

Package Display {
	Brief() {
		;; Visualizers for :Widgets:Display
		nil
	}

	Pole-Zero-Plot(poles zeros) {
		;; Visualize complex 'poles' and 'zeros' on the unit circle of the Z-plane.

		Use Graphics
		Use Algorithm

		pole(p) {
			Z = p + Complex:Cons(0 0)
			x = Coerce(Float Complex:Real(Z))
			y = Coerce(Float Complex:Img(Z))
			Seq(
				Line(x - 0.1 y - 0.1 x + 0.1 y + 0.1)
				Line(x - 0.1 y + 0.1 x + 0.1 y - 0.1))
		}

		zero(p) {
			Z = p + Complex:Cons(0 0)
			x = Coerce(Float Complex:Real(Z))
			y = Coerce(Float Complex:Img(Z))
			Circle(x y 0.1)
		}

		Viewport( 2.5 2.5
			Translate(1.25 1.25
				Stroke((1 1 1 0.5)
					Line(-2 0 2 0)
					Line(0 -2 0 2)
					Circle(0 0 1))
				Stroke((0 0.5 1 1)
					Map(pole poles))
				Stroke((1 0 0.5 1)
					Map(zero zeros))))
	}
}