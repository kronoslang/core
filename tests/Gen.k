Import Gen
Import Filter

Package Test {
	Offset-Zoo() {
		Use Gen
		Saw(110 0.5) +
			Saw-(110 Phasor(1)) +
				Tri(220 0.3) +
				Tri(221 0.7) +
				Pulse(55 0.1 0.5) +
				Pulse(55 0.1 Phasor(0.5)) * 0.15
	}

    Simple-Slower() {
    	Audio:Signal(
    		Gen:Slower(#16 {
    			Gen:Sin(Gen:Osc(Gen:Shape:Triangle 0.5 880))
    		}))
    }

    Nested-Slower() {
    	Use Gen
    	Audio:Signal(
    		Slower(#8 {
    			Sin(440 * Slower(#500 {
    				1 + Sin(1)
    				}))
    			}))
    }

    Faster-Args() {
        sr = Rate-of(Audio:Signal(0))
        Audio:Signal(
            Gen:Faster(#2 Gen:Sin sr * 1.99))
    }

    Oversampled-RM() {
    	Use Gen
    	N = #8

    	sr = Rate-of(Signal(0))

    	rm() {
			wave1 = Gen:Sin( Gen:Phasor(1.1) * sr )
			wave2 = Gen:Sin( Gen:Phasor(0.5) * sr )
			wave1 * wave2
    	}

        decimate(sig) {
            Reactive:Downsample(Filter:Halfband-HQ(sig) #2)
        }

        downsample(sig N) {
            N < #2 : sig Recur(decimate(sig) N / #2)
        }

    	downsample(Faster(N rm) N)
    }

    Library-Oversample() {
        sr = Rate-of(Gen:Signal(0))
        Gen:Oversample(#4 Gen:Saw Gen:Phasor(1) * sr * 0.5)
    }
}