
#---------------------------------
#-- Natural numbers :: (Iteration)

def zero(f, x):
    return x

def s(n):
    return lambda f, x : f(n(f,x))

def c2n(n):
    return n(lambda z: z+1, 0)

def n2c(n):
    def church_nat(f, x):
        for i in range(n):
            x = f(x)
        return x
    return church_nat

one = s(zero)
two = s(one)
three = s(two)

print(c2n(zero))  # 0
print(c2n(one))   # 1
print(c2n(two))   # 2

def add(n, m):
    return lambda f, x : n(f,m(f,x))

print(c2n(add(one, two))) # 3

def curry2(f):
    return lambda x: lambda y: f(x, y)

def mult(n, m):
    return lambda f, x: n(curry2(m)(f), x)

print(c2n(mult(three, two))) # 6

def exp(n, m):
    return lambda f, x: m(curry2(n),f)(x)

print(c2n(exp(three, two))) # 9

#---------------------------------
#-- Boolean :: (Selection)

def true(x, y):
    return x

def false(x, y):
    return y

def c2b(b):
    return b(True,False)

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

print(c2b(true)) # True
print(c2b(false)) # False
print(c2b(neg(true))) # False
print(c2b(conj(true,true))) # True
print(c2b(conj(false,true))) # False
print(c2b(disj(false,true))) # True
print(c2b(disj(false,false))) # False
print(c2b(xand(false,false))) # True
print(c2b(xand(false,true))) # False
print(c2b(xorr(false,true))) # True
print(c2b(xorr(true,true))) # False

#---------------------------------
#-- Pair :: (Prepended Selection)

def con(x, y):
    return lambda b: b(x,y)

def fst(p):
    return p(true)

def snd(p):
    return p(false)

def c2p(p):
    return fst(p), snd(p)

print(c2p(con(1,3))) # (1, 3)
pair = con(one,three)
print(c2n(fst(pair))) # 1
print(c2n(snd(pair))) # 3

#---------------------------------
#-- Integer :: (Pair of Nat)

def c2i(i):
    return c2n(fst(i)) - c2n(snd(i))

def n2i(n):
    return con(n, zero)

def add_i(i, j):
    return con(add(fst(i), fst(j)), add(snd(i), snd(j)))

def minus(i, j):
    return con(add(fst(i), snd(j)), add(snd(i), fst(j)))

def mult_i(i, j):
    return con(add(mult(fst(i), fst(j)),
                   mult(snd(i), snd(j))),
               add(mult(fst(i), snd(j)),
                   mult(snd(i), fst(j))))

n_one_ = minus(n2i(zero), n2i(one))
n_one = con(two, three)
n_two = add_i(n_one_, n_one)
n_three = add_i(n_one, n_two)
n_six = mult_i(n_three, n2i(two))

print(c2i(n_one_)) # -1
print(c2i(n_one)) # -1
print(c2i(n_two)) # -2
print(c2i(mult_i(n_three, n_two))) # 6
print(c2i(n_six)) # -6


#---------------------------------
#-- List :: (Fold)
# from https://stackoverflow.com/a/9752426

empty = lambda f, b: b

def cons(a, ls):
    return lambda f,b: ls(f,f(b,a))

def push_back(ls, x):
    ls.append(x)
    return ls

def c2l(ls):
    return ls(push_back, [])

def printNatList(ls):
    print(list(map(c2n, c2l(ls))))

print(c2l(cons(1, cons(2, empty)))) # [1, 2]
ls1 = cons(one, cons(three, cons(two, empty)))
printNatList(ls1) # [1,3,2]

def append(xs, ys):
    return lambda f,b: ys(f,xs(f,b))

ls2 = cons(two, cons(three, cons(one, empty)))
ls3 = append(ls1, ls2)
printNatList(ls3) # [1, 3, 2, 2, 3, 1]

def reverse(ls):
    return ls(lambda b,a: cons(a,b), empty)

printNatList(reverse(ls2)) # [1, 3, 2]

def head(ls):
    return snd(ls(lambda b,a:
        fst(b)(con(true,snd(b)),(con(true,a)))
    , con(false,None)))

print(c2n(head(ls2))) # 2

def tail(ls):
    return reverse(snd(ls(lambda b,a:
        fst(b)(con(true,cons(a,snd(b))),(con(true,snd(b))))
    , con(false,empty))))

printNatList(tail(ls3)) # [3, 2, 2, 3, 1]

#---------------------------------
#-- Recursion :: (Y combinator)
# \f. (\x. f (x x)) (\x. f (x x))
# from https://en.wikipedia.org/wiki/Fixed-point_combinator

def y(f):
    return (lambda x: f(x(x)))(lambda x: f(x(x)))

def isZero(n):
    return n((lambda b: false), true)

print(c2b(isZero(zero))) # true
print(c2b(isZero(one))) # False

def p(n):
    return snd(n(lambda x:
        fst(x)(con(true,s(snd(x))),(con(true,zero)))
    , con(false,zero)))

print(c2n(p(two))) # 1
print(c2n(p(one))) # 0
print(c2n(p(one))) # 0

def minus_n(n, m):
    # we don't need lambda f,x: here!
    return m(p, n)

print(c2n(minus_n(three, two))) # 1
print(c2n(minus_n(two, zero))) # 2
print(c2n(minus_n(one, two))) # 0

def fact(f):
    return lambda n: isZero(n)(one, (mult(n,f(p(n)))))

#y(fact)(3)

def y_lazy(f):
    return lambda: (lambda x: f(x(x)))(lambda x: f(x(x)))

def fact_lazy(f):
    return lambda n: isZero(n)(lambda: one, lambda: (mult(n,f(p(n))())))

print(c2n(y(fact_lazy)()(3)()))

#def factorial(n)
#
#def equal_nat(n, m)
#---------------------------------
#-- HashMap


#---------------------------------
#-- Rational number :: (Pair of Int)
#
#def c2r(r):
#    return c2i(fst(r)) / c2i(snd(r))
#
#def i2r(r):
#    return con(r, one)
#
#def add_r(r, s):
#    return cons(add_i(mult_i(snd(r), fst(s)),
#                      mult_i(fst(r), snd(s))),
#                mult_i(fst(r), fst(s)))
#
#def exp_i(i, j): # exp returns nat but exp_i returns rat. why?
#
