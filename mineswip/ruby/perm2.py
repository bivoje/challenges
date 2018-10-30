
def perm(elems, n):
    if n == 0:
        yield []
        return

    for x in elems:
        elems.remove(x)
        for p in perm(elems, n-1):
            yield [x] + p
        elems.add(x)

whole = set(range(1,13))

for f, g, k, l in perm(whole, 4):
    if f != k+l+2*g:
        continue
    abcdehij = whole - {f, g, k, l}
    for c, d, e in perm(abcdehij, 3):
        if c != d+2*e:
            continue
        if c+d+e != f+g+k+l:
            continue
        abhij = abcdehij - {c, d, e}
        for h, i, j in perm(abhij, 3):
            if 2*h+i != 3*j:
                continue
            ab = abhij - {h, i, j}
            for a, b in perm(ab, 2):
                if 3*(h+i+j)+a != c+d+e+f+g+k+l+3*b:
                    continue
                print(a,b,c,d,e,f,g,h,i,j,k,l)
