Package Exception {
	Type Type-Error
	Type Invalid-Argument
	Type Unexpected
}

Try-Catch(try catch...) {
	Find-Handler = {
		((tag msg) t h cs) = arg
		Equal-Type(tag t) : h(msg) Recur((tag msg) cs)
	}

	Try-Catch = Handle(try() {
			(tag msg)  = Break(Exception arg)
			Find-Handler((tag msg) catch...)
		})
}


Package Throw {
	Unexpected(msg) {
		Unexpected = With-Type(Exception:Unexpected msg)
	}

	Type-Error(msg) {
		Type-Error = With-Type(Exception:Type-Error msg)
	}

	Invalid-Argument(msg) {
		Invalid-Argument = With-Type(Exception:Invalid-Argument msg)
	}

	With-Type(tag message) {
		With-Type = Raise(tag message)
	}
}