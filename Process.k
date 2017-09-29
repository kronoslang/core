Import Algorithm
Import Exception

Package VM {
	Package World {
		Type World

		Cons(env-id) {
			Make(World env-id)
		}

		Decons(w) {
			Break(World w)
		}
	}

	Type Op
	Type Instance-ID

	Instance(id) {
		Make(Instance-ID id)
	}

	Step(op args) {
		Eval(Break(Op op) args)
	}

	Run(a) {
		Run = Step(a World:Cons(External(World:World 0q)))
	}

	Output(action-or-value) {
		Output = Run(Actions:Print-One(action-or-value "\n"))
		Output = Run(action-or-value)
	}

	FFI(world sym args) {
		World:Cons(
			First(
				Foreign-Function("int64" sym "int64"	
					world args)))
	}

	Make-Op(sym args) {
		Make(VM:Op {
			FFI(World:Decons(arg) sym args)
		})
	}
}

Package Actions {
	Use Algorithm

	Print-One(a) { 
		VM:Make-Op("kvm_print!" 
			"const char*" "out"
			"const char*" String:Interop-Format(a)
			"const void*" [a])
	}

	Start(closure) {
		VM:Make-Op("kvm_start!"
			"typeof"		closure
			"cons void*"	closure)
	}

	Stop(instance) {
		Stop = Throw:Type-Error(instance " is not an instance that can be stopped.")
		Stop = VM:Make-Op("kvm_stop!"
			"int64" Break(VM:Instance-ID instance))
	}

	Compose(inner outer) { 
		VM:Make-Op("kvm_compose!"
			"typeof" inner
			"const void*" inner
			"typeof" outer
			"const void*" outer)
	}

	If(truth then else) {
		Make(VM:Op {
			world = VM:World:Decons(arg)

			then-branch = { VM:Step(then world) }
			else-branch = { VM:Step(else world) }
			
			FFI(world "kvm_branch!"
				"sizeof" truth 
				"const void*" truth
				"typeof" then-branch
				"const void*" then-branch
				"typeof" else-branch
				"const void*" else-branch)
		})
	}

	Do(actions) { Make(VM:Op {
		Reduce((w op) => VM:Step(op w) arg actions)
	}) }	

	For(values body) { Make(VM:Op {
		Reduce((world value) => VM:Step(body(value) world) arg values)
	}) }

	Pr(values) {
		For(values Print-One)		
	}

	PrLn(values) {
		Do(
			For(values Print-One)
			Print-One("\n"))
	}
}

Invoke-With(left right) {
	Invoke-With = right(left)
	Invoke-With = When(Class-of(left) == VM:Op Actions:Compose(left right))
}

