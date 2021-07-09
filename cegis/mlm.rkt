#lang rosette

(define-symbolic T (~> integer? integer? boolean?))
(define-symbolic E (~> integer? integer? boolean?))
(define-symbolic x y z w integer?)

(define (I e) (if e 1 0))

(define-symbolic rn (~> integer? integer?))
(define-symbolic sum-uf (~> integer? integer? integer?))

(define (sum x f) (sum-uf x (* (f x) (I (= (rn x) x)))))
(define (exist x f) (sum-uf x (* (f x) (f (rn x)))))

;; [t.k = t′.k] × R(t) × R(t′) = [t = t′] × R(t)
(assert (forall (list x y z w)
                (eq? (&& (E x z) (E y w) (= z w))
                     (&& (E x z) (= z w) (= x y)))))

(verify (assert (= (sum z (λ (z) (I (E z y))))
                   (exist z (λ (z) (I (E z y)))))))

;; exist z . T(x, z), E(z, y).
(define e (exist z (λ (z)
                     (* (I (T x z))
                        (I (E z y))))))

;; sum z . [T(x, z)] * [E(z, y)].
(define s (sum z (λ (z)
                   (* (I (T x z))
                      (I (E z y))))))

(verify (assert (= e s)))
