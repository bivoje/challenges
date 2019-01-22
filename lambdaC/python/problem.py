
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
    pass

def mult(n, m):
    pass

def exp(n, m):
    pass

def n2c(n):
    pass
