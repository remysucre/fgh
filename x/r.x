def tc(x, y, w) = vertex(x) and x = y and w = 0
def tc(x, y, w) = exists(z, w1: tc(x,z,w1) and edge(z, y) and w=w1+1)

def apsp[x, y] = Min[w: tc(x, y, w)]

def result[x] = Max[y: apsp[x, y]]
