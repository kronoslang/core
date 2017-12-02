Import Exception

Package VM {
	Package World {
		Type World

		Cons(env-id bus-ty) {
			Make(World env-id bus-ty)
		}

		Decons(w) {
			Break(World w)
		}

		Id(w) {
			(Id _) = Decons(w)
		}

		Update(world new-id) {
			(id bus) = Decons(world)
			Cons(new-id bus)
		}
	}

	Type Op
	Type Instance

	Step(op world) {
		(closure return) = Break(Op op)
;		FFI[closure(world) "kvm_drop!"]
		closure(world)
	}

	Step-Push(op world) {
		(closure return) = Break(Op op)
		closure(world)
	}

	Execute(a bus) {
		Step(a World:Cons(External(World:World 0q) bus))
	}

	Output(action-or-value bus) {
		Use Actions
		Output = Execute(
			Do(
				Print-One(action-or-value) 
				Print-One("\n")) 
			bus)

		Output = Execute(action-or-value bus)
	}	

	FFI(world sym args) {
		World:Update(world
			First(
				Foreign-Function("int64" sym "int64"	
					World:Id(world) args)))
	}

	Make-Op(sym args) {
		Make(VM:Op {
			FFI(arg sym args)
		} nil)
	}

	; for now support 2:2 1:2 and 2:1
	Mix(bus sig _) {

		(bl br) = bus
		(sl sr) = sig
		sm = sig * 0.5

		; environment will accept 2:2, 1:1, 2:1 and 1:2
		Mix = Throw:Invalid-Argument("No mixer available for " sig)
		Mix = bus + sig
		Mix = bus + sl + sr
		Mix = (bl + sm br + sm)
		Mix = (bl + sl br + sr)
	}

	Mix-Check(bus sig _) {
		mixed = Mix(arg)
		Mix-Check = When(Equal-Type(bus mixed) mixed)
	}

	Instance-Wrapper(mixbus closure) {
		sig = closure( Make(Instance Self-ID() nil) )
		bus = External(("unsafe" "accumulator") mixbus())
		
		When(Equal-Type(Class-Of(sig) Op) 
				Effect-Dependency(bus sig)			
			 Otherwise
				Handle(Mix-Check[bus sig]
				   { Effect-Dependency(bus sig) }) )
	}

	Pop(world ty) {
		(new-id data _) = Foreign-Function["int64" "kvm_pop!"
			"int64" World:Id(world) 
			"sizeof" ty
			"void*" ty]
		(World:Update(world new-id) data)
	}

	Output-Of(inst) {
		(id r) = Break(Instance inst)
		Key-to-Type(r)
	}


	Loop(body finally set...) {
		Loop = Throw:Invalid-Argument(set... "must contain at least two elements")

		(y1 y2) = set...
		Loop = finally(y2 y1)

		(x1 x2 xs) = set...
		Loop = Nil?(xs) : finally(x2 x1)
						  Recur(body finally body(x2 x1) xs) 
	}

	Last(set...) {
		Last = set...
		(x xs) = set...
		Last = Nil?(xs) : x Recur(xs)
	}
}

Package Actions {
	Print-One(a) { 
		VM:Make-Op["kvm_print!" 
			"const char*" "out"
			"const char*" String:Interop-Format(a)
			"const void*" [a]]
	}

	Start(fn) {
		;; Plug the function 'fn' into the mix bus of the environment
		Make(VM:Op {
			(id bus) = VM:World:Decons(arg)
			audio-adapter = { VM:Instance-Wrapper(bus fn) }
			VM:FFI[arg "kvm_start!"
				"sizeof"		audio-adapter
				"typeof"		audio-adapter
				"const void*"	audio-adapter]
		} Make(VM:Instance 0q "n/a" ))
	}

	Stop(instance) {
		Stop = Throw:Type-Error(instance " is not an instance that can be stopped.")
		(id returns) = Break(VM:Instance instance)
		Stop = VM:Make-Op["kvm_stop!"
			"int64" id]
	}

	Call(fn arguments) {
		Make(VM:Op { 
			VM:Step(fn(arguments) arg) 
		} nil)
	}

	After(duration actions) {
		action = Do(actions)
		Make(VM:Op {
			world = arg
			(raw-world bus) = VM:World:Decons(world)
			now  = First(Foreign-Function["int64" "kvm_now" "int64" raw-world])
			rate = First(Foreign-Function["float" "kvm_scheduler_rate" "int64" raw-world])
			(_ action-closure) = Specialization-Monitor(
				"kvm_anticipate_after"
				{ VM:Step(action world) }
			)

			VM:FFI[world "kvm_schedule!"
				"int64"  now + Coerce(Int64 rate * duration)
				"sizeof" action-closure
				"typeof" action-closure
				"const void*" action-closure]
		} nil)
	}

	Send-To(instance method parameter) {
		(id _) = Break(VM:Instance instance)
		Make(VM:Op {
			VM:FFI[arg "kvm_dispatch!"
			"int64" id 
			"const char*" method
			"sizeof" parameter 
			"const void*" parameter
			"const char*" String:Interop-Format(parameter)
			"const void*" parameter]
		} nil)
	}

	Method(instance method parameter) {
		(id returns) = Break(VM:Instance instance)
		rv = Key-to-Type(returns)
		Make(VM:Op {
			VM:FFI[arg "kvm_dispatch!"
			"int64" id 
			"const char*" method
			"sizeof" parameter 
			"const void*" parameter
			"const char*" String:Interop-Format(parameter)
			"void*" rv]
		} rv)
	}

	Invoke-With(inner outer) { 
		Make(VM:Op {
			w1 = arg
			(_ returns) = Break(VM:Op inner)
			w2 = :VM:Step-Push(inner w1)
			(w3 bind) = :VM:Pop(w2 returns)
			:VM:Step(Do(outer(bind)) w3)
		} nil)
	}

	Return(value) {
		Make(VM:Op {
			world = arg
			VM:FFI[world "kvm_push!"
					"sizeof" value
					"const void*" value]
		} value)
	}

	If(truth then else) {
		Make(VM:Op {
			world = arg

			(_ then-branch) = Specialization-Monitor("kvm_anticipate_then" { VM:Step(then world) })
			(_ else-branch) = Specialization-Monitor("kvm_anticipate_else" { VM:Step(else world) })
			
			VM:FFI[world "kvm_branch!"
				"sizeof" truth 
				"const void*" truth
				"sizeof" then-branch
				"typeof" then-branch
				"const void*" then-branch
				"sizeof" else-branch
				"typeof" else-branch
				"const void*" else-branch]
		} nil)
	}

	Do(actions) { 
		(_ returns) = Break(VM:Op VM:Last(actions))

		Make(VM:Op {
			VM:Loop(VM:Step VM:Step-Push arg actions)
		} returns) 
	}	

	For(values body) { 
		pval = Pair?(values) : First(values) values

		(_ returns) = Break(VM:Op body(pval))

		Make(VM:Op {
		VM:Loop((x world) => VM:Step(body(x) world)
				(x world) => VM:Step-Push(body(x) world) 
				arg values)
		} returns) 
	}

	Pr(values) {
		For(values Print-One)
	}

	PrLn(values) {
		Do(
			For(values Print-One)
			Print-One("\n"))
	}

	Bind(name value) {
		;; dynamically (re)set a constant in the code library.
		;; only available in REPL.
		VM:Make-Op["kvm_repl_bind" "const char*" name "typeof" value "const void*" value]
	}

	New(name object) {
		Do(id <- Start(object) Bind(name id))
	}

	Friend(object) {
		Do(id <- Start(object) Bind("" id))
	}
}

Invoke-With(left right) {
	Invoke-With = right(left)
	Invoke-With = When(Equal-Type(Class-Of(left) VM:Op) Actions:Invoke-With(left right))
}

Import Gen
Import Algorithm

Bleep(dur freq) {
	Use Actions
	Do( 
		id <- Start('Wave:Sin(freq))
		After(dur Stop(id)))
}

Test(N) {
	Use Algorithm 
	Actions:For(Expand(N (+ 1) 0) i => Bleep(i * 0.1 220 + i))
}

Pulse(freq w) {
	Use Actions 
	Do( id <- Start('Audio:Signal(0.5)) 
		After( w / freq  Stop(id) ) 
		After( 1 / freq  Call(Pulse freq w) ) ) 
}