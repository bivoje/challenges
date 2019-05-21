
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


def identity(x):
  return x

def const(x):
  return lambda y: x

def pred(n):
  return lambda f, x: curry2(n)(lambda g: lambda h: h(g(f)))(const(x))(identity)

def sub(n, m):
  return m(pred, n)


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
    return lambda x,y: b(y,x)

def conj(b1, b2):
    return lambda x,y: b1(b2(x,y),y)

def disj(b1, b2):
    return lambda x,y: b1(x,b2(x,y))

def xand(b1, b2):
    return lambda x,y: b1(b2(x,y),b2(y,x))

def xorr(b1, b2):
    return lambda x,y: b1(b2(y,x),b2(x,y))
