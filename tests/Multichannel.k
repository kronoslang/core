Import Gen
Type Multichannel

Package Multichannel {
    Cons(channels) {
        Cons = Make(:Multichannel channels)
    }

    As-Tuple(mc) {
        As-Tuple = Break(:Multichannel mc)
    }

    Binary-Op(op a b) {
        Binary-Op = Multichannel:Cons(
                Algorithm:Zip-With(op 
                    Multichannel:As-Tuple(a) 
                    Multichannel:As-Tuple(b)))
    }
}

Add(a b) {
    Add = Multichannel:Binary-Op(Add a b)
}   

Sub(a b) {
    Sub = Multichannel:Binary-Op(Sub a b)
}   

Mul(a b) {
    Mul = Multichannel:Binary-Op(Mul a b)
}   

Package Type-Conversion {
    Explicit(type data) {
        channels = Multichannel:As-Tuple(type)
        Explicit = When(Real?(data) 
            Multichannel:Cons(
                Algorithm:Map('data channels)))
    }
}

Multichannel?(mc) {
    Multichannel? = nil
    Multichannel? = Require(Multichannel:As-Tuple(mc) True)
}

Package Type-Conversion {
    Implicit?(from to) {
        Implicit? = When(Real?(from) & Multichannel?(to) True)
    }
}

MyFilter(sig tone) {
    zero = sig - sig
    y1 = z-1(zero y0)
    y0 = y1 + tone * (sig - y1)
    MyFilter = y0
}

Package Test {
    Dual-Filter() {
        noise = Noise:Pseudo-White(0.499d)
        stereo-noise = Multichannel:Cons(noise noise)
        stereo-mod = Multichannel:Cons(Wave:Sin(1) Wave:Sin(1.2)) * 0.5 + 0.5
        Dual-Filter = MyFilter(stereo-noise stereo-mod)
    }
}