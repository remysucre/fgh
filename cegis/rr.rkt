#lang rosette
(require "core/lib.rkt")

(decl rel E R (~> id? id? bool?))
(decl var x y z id?)

(idb (r x y) `(I (rel R ,x ,y)))

(stratum (f r)
     (λ (x y)
          (sum z (* (I (rel E x z))
                    (r z y)))))

(stratum (g r)
     (λ (y) (r 1 y)))

(define-symbolic a b c integer?)
(assert (forall (list a b c)
                (<=> (&& (E a b) (R b c))
                     (&& (R a b) (E b c)))))

(optimize)

;; (+ (I (E 1 y)) (sum z (* (S z) (I (E z y)))))
