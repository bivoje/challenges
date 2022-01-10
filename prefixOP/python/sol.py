
strexpr = intput()

def toPrefix(infixStr):
    infixStr = infixStr.replace("+", " + ")
                       .replace("-", " - ")
                       .replace("(", " ( ")
    tokens = infixStr.split()

    builder = []
    stack = []
    for token in tokens:
        if token == ")":
            stack.pop()
