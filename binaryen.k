Import Vector
Import Algorithm

:Vector:Pack(values...) #[Override Pattern] {
	; disable SIMD on Binaryen
	Rest(nil)
}

:Vector:Broadcast(width value) #[Override Pattern] {
	; simulate broadcast operation
	:Vector:Cons(Algorithm:Expand(width '_ value))
}