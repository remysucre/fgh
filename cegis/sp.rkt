#lang rosette
(require "core/lib.rkt")

;; declare the types of relations and variables
(decl rel E R (~> id? id? int? bool?))
(decl var x y z id?)
(decl var w w1 w2 int?)

;; define helper functions
(def (weight w x z)
  ;; min w . 1_{E(x,z,w)} + w.
  (sum w (* (I (rel E x z w)) w)))

;; recursive relation
(idb (r x y w) `(I (rel R ,x ,y ,w)))

;; recursive stratum
#;(stratum (f r)
  (λ (x z w) (+
     ;; R(x,z,w) :- E(x,z,w).
     (I (rel E x z w))
     ;; R(x,z,w) :- R(x,y,w1), E(y,x,w2), w=w1+w2.
     (sum y (sum w1 (sum w2
       #;(* (* (r x y w1) (r y z w2)) (I (= w (* w1 w2))))
       #;(* (* (I (rel E x y w1)) (r y z w2)) (I (= w (* w1 w2))))
       (* (* (r x y w1) (I (rel E y z w2))) (I (= w (* w1 w2))))))))))
(stratum (f r)
  (λ (x z w)
     ;; R(x,z,w) :- R(x,y,w1), E(y,x,w2), w=w1+w2.
     (sum y (sum w1 (sum w2
       #;(* (* (r x y w1) (r y z w2)) (I (= w (* w1 w2))))
       #;(* (* (I (rel E x y w1)) (r y z w2)) (I (= w (* w1 w2))))
       (* (* (r x y w1) (I (rel E y z w2))) (I (= w (* w1 w2)))))))))

;; "return" stratum
(stratum (g r)
  ;; S[x,z] = min w . R(x,z,w) + w.
  (λ (x z) (sum w (* (r x z w) w))))

(optimize)

;; (+ (weight w x z) (sum y (* (weight w2 y z) (S x y))))
