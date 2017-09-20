Import Algorithm
Import Reflection
Import Closure
Import Coerce
Import Implicit-Coerce
Import Approx
Import Math
Import Vectorization
Import Complex
Import Lazy

Test(n) { 
	Test = Algorithm:Reduce((a b) => (b a) Algorithm:Expand(n x => x + 1 1))
}

Test2(n) {
	series = Algorithm:Expand(n x => x + #1 #1)
	Test2 = Algorithm:Map(Approx:Factorial series)
}

Test3(n) {
	Test3 = Series:Arithmetic(1 2) >> Series:Take(n _) >> Lazy:Force(_)
}

Synth() {
	Synth = 2 * Abs(Oscillator(IO:Parameter("Freq" #1 #2 #3) / Reactive:Rate(IO:Audio-Clock(0)))) - 1
}

Parse-Midi(midievt) {
	status = BitShiftRight(midievt 16i) & 0xff
	a = BitShiftRight(midievt 8i) & 0xff
	b = midievt & 0xff
	Parse-Midi = (status a b)
}


GateTest() {
	midi = Parse-Midi(Reactive:Resample(External("midi" 0i) Reactive:Tick("midi" #5)))
	(status a b) = midi

	count = z-1(0i count + (1i & status == 0x90) - (1i & status == 0x80))

	GateTest = count
}

Si-Series(x order) {
	Use Math

	coefs = [3.14159 -1.72257 0.510033 -0.0856092 0.00912732 -0.000670039 0.0000358694]
	Si-Series = x * Math:Horner-Scheme(x * x coefs)
}

Si-Adhoc(x) {
	xp = x * Approx:Pi
	Si-Adhoc = (Approx:Pi / #2) - (Math:Cos(xp) / xp)
}

Si-Approx(x) {
	series = Si-Series(x #7)
	adhoc = Si-Adhoc(x)
	Si-Approx = Ternary-Select(Abs(x) > 2 adhoc series) & (x != 0)
}
