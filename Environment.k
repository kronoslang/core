Package VM {
	Type Action

	Package RT {
		Type World
	}



	Do(actions) {
		; string actions sequentially and pipe 'World' through them

	}


	Run(a) {
		env = External(Action 0q)

	}	
}