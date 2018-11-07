Import IO
Import VM

Package Widget {
	Linear(min max crv) {
		ui => min + (max - min) * ui
	}

	Polynomial(min max exp) {
		ui => min + Math:Pow(ui exp) * (max - min)
	} 

	Exponential(min max crv) {
		ui => min * Math:Pow(max / min ui)
	}

	Slider(key deflt behavior params) {
		mapping = behavior(params)
		mapping(Control:Param(key deflt))
	}

	Dial = Slider	
}

Package Graphics {
	API(func params) {
		VM:Make-Op[String:Append(String:Append("Gfx" func) "!")
			"const float*" Map(p => Coerce(Float p) params) 
			"int32" Coerce(Int32 Arity(params))]
	}

	PolyLine(coords) {
		API("PolyLine" coords)
	}

	Line(x1 y1 x2 y2) {
		PolyLine[x1 y1 x2 y2]
	}

	Circle(x y r) {
		API("Circle" x y r)
	}

	Area-Plot(x y w values) {
		API("AreaPlot" x y w values)
	}

	Stroke((r g b a) shapes) {
		Use Actions
		Do(
			API("Push" 1)
			API("Stroke" r g b a)
			Do(shapes)
			API("Pop" 1))
	}

	Fill((r g b a) shapes) {
		Use Actions
		Do(
			API("Push" 1)
			API("Stroke" r g b a)
			Do(shapes)
			API("Pop" 1))
	}

	Rotate(angle shapes) {
		Use Actions
		Do(
			API("Push" 0)
			API("Rotate" angle)
			Do(shapes)
			API("Pop" 0))
	}

	Scale(x y shapes) {
		Use Actions
		Do(
			API("Push" 0)
			API("Scale" x y)
			Do(shapes)
			API("Pop" 0))
	}

	Translate(x y shapes) {
		Use Actions
		Do(
			API("Push" 0)
			API("Translate" x y)
			Do(shapes)
			API("Pop" 0))
	}

	Canvas(id shapes) {
		Use Actions
		Do(
			VM:Make-Op["GfxContext" "const char*" id]
			shapes)
	}

	Viewport(width height shapes) {
		Use Actions
		Do(
			API("Viewport" width height)
			shapes)
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
		Use Actions

		pole(p) {
			Z = p + Complex:Cons(0 0)
			x = Coerce(Float Complex:Real(Z))
			y = Coerce(Float Complex:Img(Z))
			Do(
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
					Line(-1 0 1 0)
					Line(0 -1 0 1)
					Circle(0 0 1))
				Stroke((0 0.5 1 1)
					For(poles pole))
				Stroke((1 0 0.5 1)
					For(zeros zero))))
	}
}