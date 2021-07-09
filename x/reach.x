def tc(x, y) = vertex(x) and x = y or exists(t: tc(x, t) and edge(t, y))
def r(y) = tc(30, y)

def result = r
