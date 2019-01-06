
# walking
# - 3     - 3    
# - x     - 2
# - n     - x n
# - - -   - - - -

# search order
#   X
# 1 x 3
#   2

N = int(input(''))
target = int(input(''))

screen = [None] * (N+2)
for i in range(0, N+2): # for [0, N+1]
    screen[i] = [None] * (N+2)

for i in range(0, N+2): # for [0, N+1]
    screen[i][0]   = -1
    screen[i][N+1] = -1
    screen[0][i]   = -1
    screen[N+1][i] = -1

def rotL(cx, cy, x, y):
    #print("rot!", cx + y - cy, cy + cx - x)
    return cx + y - cy, cy + cx - x

num = N * N
X, Y = 1, 0 # old pos
x, y = 1, 1 # new pos

while True:
    #print((X, Y), "->", (x, y), num)
    if num == target:
        tarx, tary = x, y
    screen[y][x] = num
    num -= 1

    for _d in range(0, 4): # for 4 direction
        X, Y = rotL(x, y, X, Y) # try position (X,Y)
        if not screen[Y][X]: # not been at (X,Y)
            X, Y, x, y = x, y, X, Y
            break
    else: # no possible move. escape while loop
        break

for j in range(1, N+1):
    #print(' '.join(map(lambda s: f'{s: >2}', screen[j][1:N+1])))
    print(' '.join(map(str, screen[j][1:N+1])))

print(tary, tarx)
