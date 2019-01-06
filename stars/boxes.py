
N = int(input(""))

def put(*strs):
    print(''.join(strs), end='')

def endl():
    print('')

def hori(N, wrap):
    width = 1 + 4 * (N-wrap)
    put("* " * (wrap-1)) # wrap side-L
    put('*' * width) # box top
    put(" *" * (wrap-1)) # wrap side-R
    endl()

def spac(N, wrap):
    width = 1 + 4 * (N-wrap)
    put("* " * wrap) # wrap side-L
    put(' ' * (width-4)) # spacing
    put(" *" * wrap) # wrap side-R
    endl()

for i in range(1-N, N): #[-(N-1), N-1]

    wrap = N-abs(i)
    if i < 0:
        hori(N, wrap)
        spac(N, wrap)

    elif i > 0:
        spac(N, wrap)
        hori(N, wrap)

    else: #wrap == 0:
        hori(N, wrap)
