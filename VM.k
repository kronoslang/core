Import Exception
Import Reflection

; this is very compact to save rpc bandwidth
Type pk

Unwrap(sig) #[Pattern] {
	Unwrap = Break(Class-of(sig) sig)
	Unwrap = Vector:Unpack(sig)
}

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

	Package Output-Method {
		Type Audio
		Type Text
	}

	Step(op world) {
		(closure return) = Break(Op op)
;		FFI[closure(world) "kvm_drop!"]
		closure(world)
	}

	Step-Push(op world) {
		(closure return) = Break(Op op)
		closure(world)
	}

	Execute(a bus) #[Pattern] {
		world = World:Cons(IO:Source(World:World 0q #0) bus)
		(closure return) = Break(Op a)

		Pop(closure(world) return)
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

	Command(action-or-value) {
		Command = action-or-value
		Command = Execute(action-or-value nil)
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

	Adapter(mixbus closure) {
		sig = closure( Make(Instance Self-ID() nil) )
		bus = External(("unsafe" "accumulator") mixbus())

		When(Equal-Type(Class-of(sig) Op)
				Effect-Dependency(bus Execute(sig mixbus))
			 Otherwise
				Handle(Mixer:Onto-Bus[bus sig]
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
		Loop = Nil?(y2) : y1 finally(y2 y1)

		(x1 x2 xs) = set...
		Loop = 	Nil?(xs) : finally(x2 x1)
						  Recur(body finally body(x2 x1) xs)
	}

	Last(set...) {
		Last = set...
		(x xs) = set...
		Last = Nil?(xs) : x Recur(xs)
	}

	Package Mixer {
		Mix-ZeroPad(bus sig) {

			(b bs) = bus
			(s ss) = sig

			Mix-ZeroPad = Throw:Invalid-Argument("Can't mix " sig)

			Mix-ZeroPad = bus + sig
			Mix-ZeroPad = When(Nil?(ss) bus + s)
			Mix-ZeroPad = bus + s

			Mix-ZeroPad = (b + sig Recur(bs 0))
			Mix-ZeroPad = When(Nil?(ss) b + s Recur(bs 0))
			Mix-ZeroPad = (b + s Recur(bs ss))
		}

		; for now support 2:2 1:2 and 2:1
		Mix(mixbus sig _) {
			Mix = Throw:Invalid-Argument("Don't know how to mix " sig " onto " sig)
			Mix = Mix-ZeroPad(Audio:Signal(mixbus) sig)

			; implicit mono to stereo conversion if mixbus is not mono
			sm = When(Not(Pair?(sig)) sig * 0.5)
			Mix = When(Pair?(mixbus) Recur(mixbus (sm sm) nil))

			; unwrap any user types or vectors
			Mix = Recur(mixbus Unwrap(sig) nil)
		}

		Upmix(sig1 sig2) {
			mix1 = Mix[sig1 sig2]
			mix2 = Mix[sig2 sig1]
			Arity(mix1) > Arity(mix2) : mix1 mix2
		}

		Onto-Bus(bus sig _) {
			mixed = Mix(arg)
			When(Equal-Type(bus mixed) mixed)
		}

		Channels(sigs) {
			Algorithm:Reduce(Upmix sigs)
		}

		Peak-Stream(sig peak-clock) {
			peak-reset 	   = Reactive:Clock-Edge(peak-clock)
			combined-sig   = Reactive:Abdicate(sig (sig peak-clock))

			peak+ = z-1(0 Ternary-Select(peak-reset -100000 Max(peak+ combined-sig))) 
			peak- = z-1(0 Ternary-Select(peak-reset 100000 Min(peak- combined-sig)))

			Reactive:Resample((peak+ peak-) peak-clock)
		}

		Peak-Meter(pipe sig) {
			peak-clock  = Reactive:Resample(0 Reactive:Tick(#5 ("audio" "Post")))

			peaks = Algorithm:Map(ss => Peak-Stream(ss peak-clock) As-List(sig))

			Peak-Meter = Effect-Dependency(sig
							Execute(Actions:Output-JSON( pipe
								Make(:pk peaks)) nil))

			Peak-Meter = Recur(pipe Unwrap(sig))
		}
	}
}

Package Format {
	Text(a) {
		a
	}
}

Package Actions {
	Print-One(a) {
		to-print = Format:Text(a)
		VM:Make-Op["kvm_print!"
			"const char*" "out"
			"const char*" String:Interop-Format(to-print)
			"const void*" [to-print]]
	}

	Sleep(time) {
		VM:Make-Op["kvm_sleep!" "double" Coerce(Double time)]
	}

	Output(pipe value) {
		to-print = Format:Text(value)
		VM:Make-Op["kvm_print!"
			"const char*" pipe
			"const char*" String:Interop-Format(to-print)
			"const void*" [to-print]]
	}

	Output-JSON(pipe value) {
		VM:Make-Op["kvm_print!"
			"const char*" pipe
			"const char*" String:Interop-Format-JSON(value)
			"const void*" [value]]
	}

	Display(id data) {
		Actions:Output-JSON(id data)
	}

	Start(fn) {
		;; Plug the function 'fn' into the mix bus of the environment
		Make(VM:Op {
			(id bus) = VM:World:Decons(arg)
			audio-adapter = Specialization-Monitor(
				"kvm_anticipate_start"
				{ VM:Adapter(bus fn) }
			)

			VM:FFI[arg "kvm_start!"
				"sizeof"		audio-adapter
				"typeof"		audio-adapter
				"const void*"	audio-adapter]
		} Make(VM:Instance 0q "n/a" ))
	}

	Render(audio-file num-frames sample-rate closure) {
		VM:Make-Op[
			"kvm_render!"
			"const char*" audio-file 
			"typeof" 	  closure 
			"const void*" closure 
			"float"		  Coerce(Float sample-rate) 
			"int64"		  Coerce(Int64 num-frames)]
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

			action-closure = Specialization-Monitor(
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

			then-branch = Specialization-Monitor("kvm_anticipate_then" { VM:Step(then world) })
			else-branch = Specialization-Monitor("kvm_anticipate_else" { VM:Step(else world) })

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
		pval = Pair?(values) : First(values)
			   values

		(_ returns) = Nil?(values) : (nil nil)
					  Break(VM:Op body(pval))

		For = Make(VM:Op {
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

	Instrument(sig) {
		(_ Instrument _) = Foreign-Function["int64" "kvm_test_capture!"
			"const float*" sig
			"float*" sig
			"sizeof" sig]

		Instrument = Recur(Unwrap(sig))
	}

	Prebuild-All = 1i

	Flags(raise clear) {
		Make(VM:Op {
			world = arg
			VM:FFI[world "kvm_flags!"
					"int32" raise
					"int32" clear]
		} 0i)
	}

	Test(duration obj seq) {
		Do(
			instance <- Start({ Instrument(obj()) })
		   	For(seq (time method param) =>
		   		After(time Send-To(instance method param)))
		   	After(duration Stop(instance)))
	}

	Hear(obj) {
		Do(
			instance <- Start(obj)
			After(12 Stop(instance)))
	}
}

Invoke-With(left right) {
	Invoke-With = right(left)
	Invoke-With = When(Equal-Type(Class-of(left) VM:Op) Actions:Invoke-With(left right))
}