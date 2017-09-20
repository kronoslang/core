Import Algorithm
Import Exception

Package VM {
	Use Algorithm

	Package World {
		Type World

		Cons(env-id stack) {
			Make(World env-id stack)
		}

		Decons(w) {
			Break(World w)
		}
	}

	Print(a) { {
		(id stack) = World:Decons(arg)
		(new-id _) = Foreign-Function(
			"int64" "kvm_print!" 
				"int64"       id
				"const char*" String:Convert-Native(a)
				"const void*" a)

		Print = World:Cons(new-id stack)
	} }

	Do(actions) { {
			Reduce(Eval world arg)
	} }

	Run(a) {
		a(External(World 0q))
	}	
}