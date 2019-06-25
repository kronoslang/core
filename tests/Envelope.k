Import Gen
Import Envelope

Package Test {
	FM-ADSR() {
		gate = Gen:Pulse(1.8 0.1)
		modenv = Envelope:ADSR(gate 0.04 4 0 1)
		carenv = Envelope:ADSR(gate 0.1 0.4 0.7 0.5)

		f0 = 32
		mul = 1
		modi = 16

		mod = Wave:Sin(f0 * mul + 1) * modenv
		Wave:Sin((1 + mod * modi) * f0)
	}
}