@inspect
def tc(x, y) = vertex(x) and x = y or exists(z: tc(x, z) and edge(z, y))
@inspect
def mlm[x] = sum[v: tc(x, v) ]

def result = count[mlm]
