#lang rosette
(require "core/lib.rkt")
(require rosette/lib/angelic) ; provides `choose*`
(require rosette/lib/synthax) ; provides `choose*`

;; HACK shadowing D
(decl rel D (~> id? id? int?))
(decl rel E (~> id? id? bool?))
(decl rel sigma (~> id? id? int?))

(decl var s t u v id?)

(idb (sig s t) `(rel sigma ,s ,t))

(def (delta s v t)
  (div (* (* (rel sigma s v)
           (rel sigma v t))
        (I (= (rel D s t) (+ (rel D s v) (rel D v t)))))
       (rel sigma s t)))

(assert (forall (list s t u) (<= (D s u) (+ (D s t) (D t u)))))
(assert (forall (list s t) (<=> (E s t) (= 1 (D s t)))))
(assert (forall (list s t) (<=> (E s t) (= 1 (sigma s t)))))

(assert (= (* (inv (sigma s u)) (sigma s u)) 1))
(assert (= (* (inv (sigma s t)) (sigma s t)) 1))

#;(stratum (f sig)
         (λ (v t) (+
            (I (rel E v t))
            (sum u
                 (* (* (sig u t) (I (rel E v u)))
                    (I (= (rel D v t) (+ 1 (rel D u t)))))))))

(stratum (f sig)
         (λ (v t)
            (sum u
                 (* (* (sig u t) (I (rel E v u)))
                    (I (= (rel D v t) (+ 1 (rel D u t))))))))

(stratum (g sig)
         (λ (s v)
           (sum t
                (* (I (= (rel D s t) (+ (rel D s v) (rel D v t))))
                   (div (* (rel sigma s v) (sig v t))
                        (rel sigma s t))))))

(optimize)
