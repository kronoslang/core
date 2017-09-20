Package Actions {
	Type Action

	Act = 'Make( Action Reactive:Couple(_) )

	Print(value) {
		Print = Act("send" "#pr" value)
	}

	ReadLine() {
		ReadLine = Act("rdln" nil)
	}

	Start(task) {
		Start = Act( "start" task )
	}

	Stop(task) {
		Stop = Act("stop" task)
	}

	Do(tasks) {
		Do = Act("do" tasks)
	}

	Invoke-With(value continuation) {
		Invoke-With = Act( "with" value continuation )
	}

	If(truth branches) {
		If = Act( "if" truth branches )
	}

	After(delay fn) {
		After = Act( "cb" delay Do( fn ) )
	}

	PrintLn(value) {
		PrintLn = Do( Print(value) Print("\n") )
	}

	For(values fn) {
;		For = Do( Algorithm:Map(fn values) )
		For = Act( "for" values fn )
	}

	Send-To(id method value) {
		Send-To = Act( "send2" id method value )
	}

	Write-File( path length sample-rate script ) {
		Write-File = Act( "write" path length sample-rate script )
	}

	Slurp( length sample-rate script ) {
		Slurp = Act( "slurp" length sample-rate script )
	}

	Run(token actions) {
		(result _) = Foreign-Function("int64" "Kronos_Process_Actions!" 
			"int64" 		token
			"typeof" 		actions
			"const void*" 	actions)		

		Run = Equal-Type( Class-Of(actions) Action ) : result 
													   actions
	}

	Run-or-Print(token value) {
		Run-or-Print = Equal-Type(Class-Of(value) Action) : Run(token value)
			Run(token PrintLn(value))
	}

    Play(instance events) {
        Play = For(events
            (time method value) => After(time Send-To(instance method value)))
    }

	Test(params) {
		(c seq _) = params
		Test = Start(c)
		Test = Do(id <- Start(c) Play(id seq))
	}

	Test-Dump(params) {
		Test-Dump = Write-File("#checksum-matrix" 1 44100 Test(params))
	}
}

Invoke-With(value continuation) {
	Invoke-With = When(Equal-Type(Class-Of(value) Actions:Action) 
		Actions:Invoke-With(value { Actions:Do( continuation(arg) ) } ))
	(v vs) = value
}


;Import Gen
;
;Test-Voice(freq gate) {
;	Test-Voice = Wave:Saw(freq) * gate
;}
;
;Import MIDI
;
;Voice-Allocator(table voice) {
;	Use Actions
;
;	evt = MIDI:Input()
;	(status nn vel) = (MIDI:Status(evt) MIDI:A(evt) MIDI:B(evt))
;
;	Voice-Allocator = Do(
;		If(status == 0x90 & vel != 0x00 Do( 
;					new-voice <- Start('voice(MIDI:To-Freq(nn 440) vel / 512))
;					Array:Set(table nn new-voice) )
;		   If(status == 0x80 | (status == 0x90 & vel == 0x00) Do(
;						kill-voice <- Array:Get(table nn)
;						Stop(kill-voice)))))
;}
;
;Make-Synth(voice) {
;	Use Actions
;
;	Make-Synth = Do(
;		voice-table <- Start({ Array:Cons(#128 0q) })
;		Start({ Voice-Allocator(voice-table voice) })
;	)
;}
;
