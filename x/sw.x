@function
def next(s, t) = t = s + 1 and edge(s, _) and edge(t, _)
  
@function
def r(t, j, w) = edge(j, w) and t = j
@function
def r(t, j, w) = ∃(s: next(s, t) and r(s, j, w) and 1 <= j < t)

@function
def p[t] = sum[j, w: r(t, j, w)]

@function
def s[t] = p[t] - p[t-10]

def result = s
