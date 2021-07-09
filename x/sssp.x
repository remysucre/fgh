def sd(y, d) = vertex(y) and y = 30 and d = 0 and not s[y] = _
def sd(y, d) = exists(z, d1 : sd(z, d1) and edge(z, y) and d = d1 + 1) and not sd[y] = _

def s(y, d) = s(y, d) or sd(y, d)

def ss[y] = Min[s[y]]

def result = ss
