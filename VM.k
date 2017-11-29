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
					World:Decons(world) args)))
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
		sig = closure( Make(Instance Self-ID()) )
		bus = External(("unsafe" "accumulator") mixbus)
		
		When(Equal-Type(Class-Of(sig) Op) 
				Effect-Dependency(bus VM:Run(sig))			
			 Otherwise
				Handle(Mix-Check[bus sig]
				   { Effect-Dependency(bus sig) } ))
	}

	Pop(world ty) {
		(new-world data _) = Foreign-Function["int64" "kvm_pop!"
			"int64" World:Decons(world) 
			"typeof" ty
			"void*" ty]
		(World:Cons(new-world) data)
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

	Start(closure) {
		Make(VM:Op {
			VM:FFI[arg "kvm_start!"
				"sizeof"		closure
				"typeof"		closure
				"const void*"	closure]
		} Make(VM:Instance 0q))
	}

	Friend(closure) {
		Make(VM:Op {
			VM:FFI[arg "kvm_furry_friend!"
				"sizeof"		closure
				"typeof"		closure
				"const void*"	closure]
		} Make(VM:Instance 0q))
	}

	Stop(instance) {
		Stop = Throw:Type-Error(instance " is not an instance that can be stopped.")
		Stop = VM:Make-Op["kvm_stop!"
			"int64" Break(VM:Instance instance)]
	}

	Call(fn arguments) {
		Make(VM:Op { VM:Step(fn(arguments) arg) } nil)
	}

	After(duration actions) {
		action = Do(actions)
		Make(VM:Op {
			world = arg
			raw-world = VM:World:Decons(world)
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
		id = Break(VM:Instance instance)
		VM:Make-Op["kvm_dispatch!"
			"int64" id 
			"const char*" method
			"sizeof" parameter 
			"const void*" parameter
			"const char*" String:Interop-Format(parameter)]
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
					"typeof" value
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