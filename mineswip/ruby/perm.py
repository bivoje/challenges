
def xrange(i, j):
    while i <= j:
        yield i
        i = i + 1

#for x in xrange(1,6):
#    print(x)
    

def perm(elems):
    if len(elems) == 0:
        yield []
        return
    #if len(elems) == 1:
    #    yield list(elems)
    #    return
    #if len(elems) == 2:
    #    a, b = elems
    #    yield [a, b]
    #    yield [b, a]
    #    return
    #if len(elems) == 3:
    #    a, b, c = elems
    #    yield [a, b, c]
    #    yield [a, c, b]
    #    yield [b, a, c]
    #    yield [b, c, a]
    #    yield [c, a, b]
    #    yield [c, b, a]
    #    return

    for x in elems:
        elems.remove(x)
        for p in perm(elems):
            yield [x] + p
        elems.add(x)

def part(elems, n):
    if n == 0:
        yield []
        return

    for x in elems:
        elems.remove(x)
        for p in part(elems, n-1):
            yield [x] + p
        elems.add(x)

#for f, k in part(set(range(1, 5)), 2):
#    print(f, k)

whole = set(range(1,13))

for f, g, k, l in part(whole, 4):
    if f != k+l+2*g:
        continue
    abcdehij = whole - {f, g, k, l}
    for c, d, e in part(abcdehij, 3):
        if c != d+2*e:
            continue
        if c+d+e != f+g+k+l:
            continue
        abhij = abcdehij - {c, d, e}
        for h, i, j in part(abhij, 3):
            if 2*h+i != 3*j:
                continue
            ab = abhij - {h, i, j}
            for a, b in perm(ab):
                if 3*(h+i+j)+a != c+d+e+f+g+k+l+3*b:
                    continue
                print(a,b,c,d,e,f,g,h,i,j,k,l)
