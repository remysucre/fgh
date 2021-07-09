#lang rosette/safe

;; (require rosette/solver/smt/cvc4)
;; (current-solver (cvc4))

;; T(x,y,w) :- E(x,y,w).
;; T(x,y,w) :- E(x,z,w1), T(z,y,w2), w=w1+w2.

;; Given: E . y -> x, w
;; Prove: T . x, y -> w

(define start (current-milliseconds))
;; (output-smt "/home/remywang/projects/pier")

(define-symbolic T (~> integer? integer? integer? boolean?))
(define-symbolic E (~> integer? integer? integer? boolean?))
(define-symbolic x y z w w1 w2 integer?)

;; E . y -> x, w
(assert (forall (list x y z w1 w2)
                (=> (&& (E x z w1) (E y z w2))
                    (&& (= x y) (= w1 w2)))))

;; needs induction!
;; T . x, y -> w
(assert (forall (list x y w1 w2)
                (=> (&& (T x y w1) (T x y w2))
                    (= w1 w2))))

(define (f x y w)
  (&& (T x z w1)
      (E z y w2)
      (= w (+ w1 w2))))

(verify (assert (=> (&& (f x y w1) (f x y w2))
                    (= w1 w2))))

(- (current-milliseconds) start)
