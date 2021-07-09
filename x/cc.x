def reachable(x, y) = vertex(x) and x = y or exists(t: reachable(x, t) and edge(t, y))

// Assign to each node the value of the smallest node of the scc it belongs to
def scc[x] = Min[v: reachable(x, v) ]

def result = count[scc]
