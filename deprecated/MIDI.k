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
		;; Declares an external MIDI input. Returns MIDI:Event.

		midi = Raw-Input()
		status = BitShiftRight(midi 16i) & 0xf0 ; ignore channel nibble
		channel = BitShiftRight(midi 16i) & 0x0f
		a = BitShiftRight(midi 8i) & 0xff       
		b = midi & 0xff	
		Input = Make(Event channel status a b)
	}

	Status/Channel/A/B(event) {
		;; Extract information from a MIDI:Event
		(Channel Status A B) = Break(Event event)
	}

	To-Freq(note-num A4) {
		;; Convert MIDI note number to a frequency, relative to the frequency of 'A4', note 69.
		To-Freq = A4 * Math:Pow(2 (note-num - 69) / 12)
	}
}
