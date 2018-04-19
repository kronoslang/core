Import Algorithm

VMap(fun vector) {
	VMap = When(Nil?(vector) nil)

	(x xs) = vector
	VMap = (fun(x) Recur(fun xs))

	(i1 i2 i3 i4 is) = vector
	(o1 o2 o3 o4) = Vector:Unpack(fun(Vector:Pack(i1 i2 i3 i4)))
	VMap = (o1 o2 o3 o4 Recur(fun is))
}

Package Test {
	Vector-Alignment() {
		data = Algorithm:Expand(#32 (+ 1) 11)
		Vector-Alignment = VMap(Math:Sqrt data)
	}
}