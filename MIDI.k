Package MIDI {
	Raw-Input() {
		Raw-Input = IO:Source("/midi" 0i #0)
	}

	Type Event

	Input() {
		midi = Raw-Input()
		status = BitShiftRight(midi 16i) & 0xf0 ; ignore channel nibble
		channel = BitShiftRight(midi 16i) & 0x0f
		a = BitShiftRight(midi 8i) & 0xff       
		b = midi & 0xff	
		Input = Make(Event channel status a b)
	}

	Status/Channel/A/B(event) {
		(Channel Status A B) = Break(Event event)
	}

	To-Freq(note-num A4) {
		To-Freq = A4 * Math:Pow(2 (note-num - 69) / 12)
	}
}
