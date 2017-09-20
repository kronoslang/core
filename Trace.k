Import Algorithm
Import String

Package Trace {

	Text-Node(indent sym td forms term) {		
		Text-Node = Debug-Trace(arg String:Concat(indent "Couldn't parse\n"))
		Text-Node = String:Concat(indent sym " <- " First(td) "\n" indent "-> " Rest(td) "\n")
		subnode = Curry(Text-Node String:Append("  " indent))		
		children = String:Concat("\n" 
			Algorithm:Map(subnode forms))
		Text-Node = 
			Constant?(sym) :
				String:Concat(indent "  * " forms " " td "\n")
			Nil?(td) : 
				String:Concat(indent sym children indent "-> error!\n")
				String:Concat(indent sym " <- " First(td) children indent "-> " Rest(td) "\n")
	}

	Text(fn) {
		dump = Specialization-Trace(fn)
		Text = Text-Node("" First(dump))
	}
}