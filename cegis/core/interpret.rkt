#lang rosette/safe

(require rosette/lib/destruct)
(require "ops.rkt")

(provide (all-defined-out))

;; COMMON DEFINITIONS
(define (interpret p)
  (destruct p
    [(op-I e) (I (interpret e))]
    ;; [(op-&& x y) (&& (interpret x) (interpret y))]
    ;; [(op-|| x y) (|| (interpret x) (interpret y))]
    [(op-+ x y) (+ (interpret x) (interpret y))]
    [(op-- x y) (- (interpret x) (interpret y))]
    [(op-* x y) (* (interpret x) (interpret y))]
    [(op-/ x y) (div (interpret x) (interpret y))]
    [(op-inv x) (inv (interpret x))]
    [(op-leq x y) (<= (interpret x) (interpret y))]
    [(op-eq? x y) (eq? (interpret x) (interpret y))]
    [(op-sum v e) (sum (interpret v) (interpret e))]
    ;; [(op-exists v e) (exist (interpret v) (interpret e))]
    ;; relations
    [(op-rel r xs) (apply r (map interpret xs))]
    ;; UDF
    [(op f xs) (apply f (map interpret xs))]
    ;; variables and constants
    [p p]))
