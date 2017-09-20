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
		;; Raise a 'Unexpected' exception with the message 'msg'. 'msg' is only passed to the handler if it contains no runtime data.
		Unexpected = With-Type(Exception:Unexpected msg)
	}

	Type-Error(msg) {
		;; Raise a 'Type-Error' exception with the message 'msg'. 'msg' is only passed to the handler if it contains no runtime data.
		Type-Error = With-Type(Exception:Type-Error msg)
	}

	Invalid-Argument(msg) {
		;; Raise a 'Invalid-Argument' exception with the message 'msg'. 'msg' is only passed to a handler if it contains no runtime data.
		Invalid-Argument = With-Type(Exception:Invalid-Argument msg)
	}

	With-Type(tag message) {
		;; Raise an exception with the type 'tag' and content 'message'
		With-Type = Raise(tag message)
	}
}