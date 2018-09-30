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