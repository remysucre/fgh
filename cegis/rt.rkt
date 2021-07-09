#lang rosette
(require "core/lib.rkt")
(require rosette/lib/angelic) ; provides `choose*`

(decl rel R (~> id? id? int? bool?))
(decl rel v (~> id? int? bool?))
(decl var t j id?)
(decl var w int?)

(assert (forall (list t j w) (=> (R t j w) (&& (<= 1 j) (<= j t)))))

(idb (r x y w) `(I (rel R ,x ,y ,w)))

(def (vec-get j w t)
  (sum j
       (sum w
            (* w (* (I (rel v j w))
                    (* (I (= j t))
                       (I (<= 1 t))))))))

;; R(t,j,w):-v(j,w),t=j.
;; R(t,j,w):-R(t-1,j,w),1<=j<t.
#;(stratum (f r)
     (λ (t j w)
       (+ (* (I (rel v j w)) (I (= t j)))
          (* (r (- t 1) j w)
             (* (I (<= 1 (- t 1)))
                (I (<= j (- t 1))))))))

(stratum (f r)
     (λ (t j w)
          (* (r (- t 1) j w)
             (* (I (<= 1 j #;(- t 1)))
                (I (<= j (- t 1)))))))

;; P[t]=sum[j,w:R(t,j,w)*w].
#;(stratum (g r)
     (λ (t)
       (sum j
            (sum w
                 (* (* (r t j w) w)
                    (* (I (<= 1 j)) (I (<= j t))))))))

(stratum (g r)
     (λ (t)
       (sum j
            (sum w
                 (* (r t j w) w)))))

(hash-update! type->var 'id? (curry cons (op-- t 1)))

(optimize)

;; (+ (vec-get j w t) (S (- t 1)))
