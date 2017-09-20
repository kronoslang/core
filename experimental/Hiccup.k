Import String
Import Algorithm
Import Exception
Import Complex

Package Presentation {
	Type Layer
	Package Layer {
		Cons(width height transforms content) {
			Cons = Make(Layer width height transforms content)
		}

		Width/Height/Transforms/Content(layer) {
			(Width Height Transforms Content) = Break(Layer layer)
		}
	}

	Type Primitive

	Horizontal(content) {
		Use Algorithm
		widths = Map(Layer:Width content)
		heights = Map(Layer:Height content)
		offsets = Accumulate(Add 0 widths)
		Horizontal = Layer:Cons(Reduce(Add widths) Reduce(Max heights) [] 
			Zip-With((offset child) => 
				Cons(nil nil [("translate(" Round(offset) ",0)")] child) offsets content))
	}

	Vertical(content) {
		Use Algorithm
		widths = Map(Layer:Width content)
		heights = Map(Layer:Height content)
		offsets = Accumulate(Add 0 heights)
		Vertical = Layer:Cons(Reduce(Max widths) Reduce(Add heights) [] 
			Zip-With((offset child) => 
				Cons(nil nil [("translate(0," Round(offset) ")")] child) offsets content))
	}

	Stack(content) {
		widths = Map(Layer:Width content)
		heights = Map(Layer:Height content)
		Stack = Layer:Cons(Reduce(Max widths) Reduce(Max heights) content)		
	}

	Polygon(points) {
		Polygon = Make(Primitive "polyline" Algorithm:Map((x y) => (Round(x) Round(y)) points))
	}

	Polybezier(points) {
		Polybezier = Make(Primitive "polybezier" Algorithm:Map((x y) => (Round(x) Round(y)) points))		
	}

	Rectangle(x y w h) {
		Rectangle = Polygon[(x y) (x + w y) (x + w y + h) (x y + h) (x y)]
	}

	Type G
	Group(attributes content) {
		Group = Make(G attributes content)
	}

	RGBA(r g b a) {
		RGBA = Require(a Round(r) Round(g) Round(b) a)
	}

	RGB(r g b) {
		RGB = Require(b RGBA(r g b 1))
	}

	Red =   RGB(255 0 0)
	Green = RGB(0 255 0)
	Blue =  RGB(0 0 255)

	With-Stroke((r g b a) width content) {
		With-Stroke = Group([
			"sroke-width" width 
			"stroke" Make(Hiccup:As-String "rgba(" r "," g "," b "," a ")")] 
			content)
	}

	With-Fill((r g b a) content) {
		With-Fill = Group(["fill" Make(Hiccup:As-String "rgba(" r "," g "," b "," a ")")] content)
	}

	Plot(fn width height x0 x1) {
		Use Algorithm

		num-pts = #100
		xr = x1 - x0
		delta = xr / num-pts

		xs = Expand(num-pts (+ delta) x0)
		ys = Map(fn xs)
		
		y0 = Reduce(Min ys)
		y1 = Reduce(Max ys)

		yr = y1 - y0

		pts = Zip-With((x y) => ((x - x0) * width  / xr 
							     height - (y - y0) * height / yr)
			  		    Reactive:Couple(xs ys))

		Plot = Polygon((width height) (0 height) pts)
	}
}

Type Hiccup
Package Hiccup {
	Type Keyword-Tag
	Type Symbol-Tag
	Type Props

	Cons(content) {
		Cons = Make(Hiccup content)
	}

	Keyword(kw) {
		Keyword = Make(Keyword-Tag kw)
	}

	Symbol(sym) {
		Symbol = Make(Symbol-Tag s)
	}

	attr(proplist) {
		attr = Make(Props proplist)
	}

	Add-Attributes(attrs proplist) {
		pl = Break(Props proplist)
		Add-Attributes = attr(Algorithm:Concat(attrs pl))
	}
	
	div =  Keyword("div")
	span = Keyword("span")
	p    = Keyword("p")
	h1   = Keyword("h1")
	h2   = Keyword("h2")
	h3   = Keyword("h3")

	Type As-String

	path(stroke fill svg-path) {
		path = [Keyword("path") attr("stroke" stroke "fill" fill "d" 
					Make(As-String svg-path))]
	}

	Render-Primitive(p) {
		(tag content) = Break(Presentation:Primitive p)

		polyline = {
			((x0 y0) pts) = arg
			[Keyword("path") attr("d" Make(As-String 
				("M" x0 "," y0 " ") 
				Algorithm:Map((x y) => ("L" x "," y " ") pts) "Z"))]
		}

		polybezier = {
			((x0 y0) pts) = arg
			[Keyword("path") attr("d" Make(As-String 
				("M" x0 "," y0 " ") 
				Algorithm:Map((x y) => ("T" x "," y " ") pts)))]
		}

		Render-Primitive = tag == "polyline"   : polyline(content)
						   tag == "polybezier" : polybezier(content)
						   Throw:Invalid-Argument("Unknown primtive '" tag "'")
	}

	Render-Group(g) {
		(attrs content) = Break(Presentation:G g)
		Render-Group = [Keyword("g") attr(attrs) Algorithm:Map(Render-Item content)]
	}

	Render-Layer(l) {
		Render-Layer = Rest(nil)
	}

	Render-Item(item) {
		Render-Item = Render-Primitive(item)
		Render-Item = Render-Layer(item)
		Render-Item = Render-Group(item)
	}

	Render(presentation) {
		Render = Cons[Keyword("svg") Algorithm:Map(Render-Item presentation)]
	}

	Render(z) {
		(x y) = Debug-Trace("cpx" Complex:Real(z) Complex:Img(z))
		Render = Cons[
			Keyword("svg") attr("width" 300 "height" 300)
			[Keyword("g") attr("stroke" "rgba(64,64,128,1)")
				[Keyword("circle") attr("r" 100 "cx" 150 "cy" 150)]
				[Keyword("line") attr("x1" 150 "y1" 0 "x2" 150 "y2" 300)]
				[Keyword("line") attr("x1" 0 "y1" 150 "x2" 300 "y2" 150)]]
			[Keyword("line") attr[
				"x1" 150 + Round(x * 100) 
				"y1" 150 - Round(y * 100)
				"x2" "150" "y2" "150" "stroke" "rgba(192,192,255,1)" "stroke-width" "2"]]
				]
			
	}
}

Import Gen

Source(sym) {
	Source = Hiccup:Cons(Hiccup:Keyword("pre.code") Get-Symbol-Source(sym))
}