Import Algorithm

Concat(strings) {
	Concat = Algorithm:Reduce(String:Append strings)
}

Replace-All(text find replace) {
	pos = String:Find(text find)
	remainder = String:Skip(text pos + String:Length(find))

	Replace-All = When(
		pos >= #0 
			Concat(String:Take(text pos) replace Recur(remainder find replace))
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
}