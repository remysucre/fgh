#lang rosette

(require "ops.rkt")
(require rosette/lib/destruct)

(provide (all-defined-out))

(define (exp->struct e var rel fun)
  (define (run e)
    (match e
      [`(I ,e) (op-I (run e))]
      [`(inv ,e) (op-inv (run e))]
      [`(* ,x ,y) (op-* (run x) (run y))]
      [`(+ ,x ,y) (op-+ (run x) (run y))]
      [`(- ,x ,y) (op-- (run x) (run y))]
      [`(div ,x ,y) (op-/ (run x) (run y))]
      [`(= ,x ,y) (op-eq? (run x) (run y))]
      [`(<= ,x ,y) (op-leq (run x) (run y))]
      [`(sum ,y ,e) (op-sum (run y) (run e))]
      [`(rel ,r ,vs ...) (op-rel (hash-ref rel r) (map run vs))]
      [`(,f ,vs ...) (op (hash-ref fun f) (map run vs))]
      [_ (hash-ref var e e)]))
  (run e))

(define (struct->exp e var rel fun)
  (define (run e)
    (match e
      [(op-I e) `(I ,(run e))]
      [(op-inv e) `(inv ,(run e))]
      [(op-* x y) `(* ,(run x) ,(run y))]
      [(op-+ x y) `(+ ,(run x) ,(run y))]
      [(op-- x y) `(- ,(run x) ,(run y))]
      [(op-/ x y) `(div ,(run x) ,(run y))]
      [(op-eq? x y) `(= ,(run x) ,(run y))]
      [(op-leq x y) `(<= ,(run x) ,(run y))]
      [(op-sum v b) `(sum ,(run v) ,(run b))]
      [(op-rel r es) `(rel ,(hash-ref rel r) ,@(map run es))]
      [(op f es) `(,(hash-ref fun f) ,@(map run es))]
      [_ (hash-ref var e e)]))
  (run e))

(define (make-pattern e)
  (match e
    [`(rel ,r ,xs ...) `(rel ,r ,@(map make-pattern xs))]
    [`(,o ,xs ...) `(,o ,@(map make-pattern xs))]
    [(? symbol? e) (~a '? e)]
    [_ e]))

(define semiring-path "../semiring/target/release/semiring")

(define (semiring e . args)
  (define out
    (with-output-to-string
      (λ () (parameterize
              ([current-input-port (open-input-string (~s e))])
              (apply system* (cons semiring-path args))))))
  (read (open-input-string (string-normalize-spaces out))))
