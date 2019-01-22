
def curry2(f):
    return lambda x: lambda y: f(x, y)

def uncurry2(f):
    return lambda x, y: f(x)(y)

#---------------------------------
#-- Natural numbers :: (Iteration)

def c2n(n):
    return n(lambda z: z+1, 0)

def zero(f, x):
    return x

def s(n):
    return lambda f, x : f(n(f,x))


def add(n, m):
    return lambda f, x : n(f,m(f,x))

def mult(n, m):
    return lambda f, x: n(curry2(m)(f), x)

def exp(n, m):
    return lambda f, x: m(curry2(n),f)(x)

def n2c(n):
    def church_nat(f, x):
        for i in range(n):
            x = f(x)
        return x
    return church_nat
