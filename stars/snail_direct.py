
# A
#   B E E E E
#   B b e e D
#   B b a d D
#   B c c d D
#   C C C C D

#        w-1
#(↘ (↺ (✓ → )))
#    4 sides

# N is odd in range [0, 999]
N = int(input(''))
target = int(input(''))
tarx, tary = 0, 0

screen = [None] * N
for i in range(0, N):
    screen[i] = [0] * N

def turnL(di):
    #print("turn! from", di)
    x, y = di
    return (y, -x)

num = N * N
direct = (-1, 0)
x, y = -1, -1

for width in range(N, 1, -2): # for each square of {width}
    #print("width", width)
    x += 1
    y += 1

    for _n in range(0, 4): # for 4 sides
        direct = turnL(direct)

        for _i in range(0, width-1): # walk {width - 1} steps
            #print((x, y), num)
            screen[y][x] = num
            if num == target:
                tarx, tary = x, y
            num -= 1
            x, y = x + direct[0], y + direct[1]

mid = N // 2
screen[mid][mid] = 1
if target == 1:
    tarx, tary = mid, mid

for line in screen:
    #print(' '.join(map(lambda s: f'{s: >2}', line)))
    print(' '.join(map(str, line)))

print(tary+1, tarx+1)
