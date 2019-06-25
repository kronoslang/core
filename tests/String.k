Import Algorithm

Replace-All(text find replace) {
	pos = String:Find(text find)
	remainder = String:Skip(text pos + String:Length(find))

	Replace-All = When(
		pos >= #0
			String:Concat(String:Take(text pos) replace Recur(remainder find replace))
		Otherwise
			text)
}

Package Test {
	Replace() {
		text = "apples are round, and apples are juicy."
		Replace = Replace-All(text "apples" "oranges")
	}

	Unicode() {
		ext-chars = "üåäö漢字"
		Unicode = (
		"Length of " ext-chars " is " String:Length(ext-chars) "\nCode points: " String:Decode(ext-chars))
	}

	Coercing-Concat() {
		String:Concat(1 #2 nil ["foo"] "bar" { baz } lambda => 5 { arg } Coercing-Concat)
	}
}