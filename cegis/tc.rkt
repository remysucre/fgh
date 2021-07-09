#lang rosette
(require "core/lib.rkt")

(decl rel E R (~> id? id? bool?))
(decl var x y z id?)

(idb (r x y) `(I (rel R ,x ,y)))

#;(stratum (f r)
     (λ (x y)
       (+ (I (rel E x y))
          (sum z (* (r x z)
                    (I (rel E z y)))))))
(stratum (f r)
     (λ (x y)
          (sum z (* (r x z)
                    (I (rel E z y))))))

(stratum (g r)
     (λ (y) (r 1 y)))

(optimize)

;; (+ (I (rel E 1 y)) (sum z (* (I (rel E z y)) (S z))))
