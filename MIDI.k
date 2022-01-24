Import Control

Package MIDI {
	Brief(documentation) {
		;; Interfacing with an external MIDI device.
		nil
	}

	Raw-Input() {
		Raw-Input = IO:Source("/midi" 0i #0)
	}

	Type Event

	Input() {
		;; Receive external MIDI events and output them as `MIDI:Event`.
		 Make(Event Raw-Input())
	}

	Status/Channel/A/B(event) {
		;; Extract information from a MIDI:Event
		raw = Break(Event event)
		Status = BitShiftRight((raw & 0xf00000) 16i)
		Channel = BitShiftRight((raw & 0x0f0000) 16i)
		A = BitShiftRight((raw & 0x00ff00) 8i)
		B = (raw & 0x0000ff)
	}

	Unpack(event) {
		;; Unpack MIDI event.
		;; OUTPUTS: (status a b)
		(Status(event) | Channel(event) A(event) B(event))
	}

	Pack(status a b) {
		;; Compose MIDI event from `status` byte and two parameter bytes `a` and `b`.
		Make(Event BitShiftLeft(Coerce(0i status) & 0xff 16i) |
				   BitShiftLeft(Coerce(0i a)      & 0x7f 8i)  |
				   (Coerce(0i b) & 0x7f))
	}

	Note->Freq(note-num A4) {
		;; Convert MIDI note number to a frequency, relative to the frequency of 'A4', note 69.
		A4 * Math:Pow(2 (note-num - 69) / 12)
	}

	Package Status {
		Note-On = 0x90
		Note-Off = 0x80
		Cc = 0xb0
	}

	MIDI->Freq(midi-event A4) {

		;; Convert MIDI event stream to the frequency of the most recent note-on event
		;; when the frequency of note 69 is given by `A4`.

		s = Status(midi-event)
		a = A(midi-event)
		b = B(midi-event)

		Control:Sample-and-Hold(
			Note->Freq(a A4) 
			Note-On?(midi-event))
	}

	Note-On?(midi-event) {

		;; Returns true integer bitmask when `midi-event` is a note on event.

		s = Status(midi-event)
		b = B(midi-event)

		s == 0x90 & b > 0i
	}

	Note-Off?(midi-event) {

		;; Returns true integer bitmask when `midi-event` is a note off event

		s = Status(midi-event)
		b = B(midi-event)

		s == 0x80 | (s == 0x90 & b == 0i)
	}

	Cc?(midi-event) {

		;; Returns true integer bitmask when `midi-event` is a continuous controller

		Status(midi-event) == Status:Cc
	}

	Cc?(cc midi-event) #[Extend] {

		;; Returns true integer bitmask when `midi-event` is the continuous controller number `cc`.

		Status(midi-event) == Status:Cc & A(midi-event) == Coerce(Int32 cc)
	}

	Count-Held-Notes(midi-event) {

		;; Count the number of held keys within a stream of MIDI notes.
		s = Status(midi-event)
		b = B(midi-event)


		count = Max(0i z-1(0i count) 
					+ (Note-On?(midi-event) & 1i) 
					- (Note-Off?(midi-event) & 1i))

		count
	}

	Filter(midi-event pred-fn transform-fn) {

		;; For midi-events that match the predicate function `pred-fn`, apply `transform-fn`
		;; to the tuple of status/channel and two MIDI data bytes.
		;; For example, you can map Continuous Controller 1 to 2 like this:
		;; `Filter(midi-stream Curry(Cc? 1) (s _ b) => (s 2 b))`

		(s a b) = MIDI:Unpack(midi-event)

		Algorithm:Choose(pred-fn(midi-event)
						 MIDI:Pack(transform-fn(s a b))
						 midi-event)
	}

	MIDI->Gate(midi-event) {

		;; Output 1 while there is one or more keys pressed in the `midi-event` stream,
		;; by comparing count of note-ons and note-offs. Outputs 0 when no notes are 
		;; detected.

		Count-Held-Notes(midi-event) > 0 & 1 
	}

}
