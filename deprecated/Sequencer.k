Import Actions
Import Algorithm

Package Sequence {
    Play(instance events) {
        Use Actions
        Play = Actions:For(events
            (time method value) => After(time Send-To(instance method value)))
    }

    With-Interval(interval events) {
    	Use Algorithm
    	Use Actions

    	timestamps = Expand(Arity(events) (+ interval) 0)
    	Actions:For(Zip(timestamps events) (t e) => After(t e))
    }

    With-Duration(duration events) {
    	With-Interval(duration / Arity(events) events)
    }
}

