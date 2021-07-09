@function
def D(s, t, k) = vertex(s) and s = t and k = 0
@function
def D(s, t, k) = (k = 1 + Min[v, l: edge(v, t) and s != t and D[s, v] = l])

@function
def σ(s, t, n) = vertex(s) and s = t and n = 1
@function
def σ(s, t, n) = (n = sum[v, m:
    edge(v, t) and D[s, v] + 1 = D[s, t] and s != t and σ[s, v] = m
])

@function
def B[v] = sum[s, t, b:
    s != t and s != v and t != v and D[s, t] = D[s, v] + D[v, t] and
    b = σ[s, v] * σ[v, t] / σ[s, t]
]

def result = B 
