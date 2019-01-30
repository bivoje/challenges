
def curry2(f):
    return lambda x: lambda y: f(x, y)

def uncurry2(f):
    return lambda x, y: f(x)(y)

def identity(x):
    return x

def const(x):
    return lambda y: x


#---------------------------------
#-- Natural numbers :: (Iteration)

def c2n(n):
    return n(lambda z: z+1, 0)

def zero(f, x):
    return x

def succ(n):
    return lambda f, x : f(n(f,x))
s = succ


def add(n, m):
    pass

def mult(n, m):
    pass

def exp(n, m):
    pass

def n2c(n):
    pass


#---------------------------------
#-- Natural numbers - sub <<optional>>

def nat_minus(a, b):
    return 0 if a < b else a - b


def sub(n, m):
    pass


#---------------------------------
#-- Boolean :: (Selection)

def c2b(b):
    return b(True,False)

def b2c(b):
    return true if b else false

def b2s(b):
    return "T" if b else "F"

def true(x, y):
    return x

def false(x, y):
    return y


def neg(b):
    pass

def conj(b1, b2):
    pass

def disj(b1, b2):
    pass

def xand(b1, b2):
    pass

def xorr(b1, b2):
    pass
