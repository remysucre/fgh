#lang rosette

(provide (all-defined-out))

(require "interpret.rkt" "grammar.rkt" "ops.rkt" "util.rkt")

(require rosette/lib/value-browser)

(define id? integer?)
(define int? integer?)
(define bool? boolean?)

(define symbol->rel (make-hash))
(define symbol->var (make-hash))
(define symbol->fun (make-hash))
(define var->symbol (make-hash))
(define fun->symbol (make-hash))
(define rel->symbol (make-hash))

(define type->var (make-hash))
(define type->rel (make-hash))
(define fun->type (make-hash))
(define var->type (make-hash))

(define meta (make-hash))

(define (dbg e) (begin (print e) e))

(define (types t)
  (match t [`(~> ,ts ... ,t) (cons ts t)]))

(define-syntax-rule (decl kind x ... type)
  (begin
    (define-symbolic x ... type)
    (match 'kind
      ['var (begin (hash-set! symbol->var 'x x) ...
                   (hash-set! var->symbol x 'x) ...
                   (hash-set! type->var 'type (list x ...))
                   (hash-set! var->type x 'type) ... )]
      ['rel (begin (hash-set! symbol->rel 'x x) ...
                   (hash-set! rel->symbol x 'x) ...
                   (hash-set! type->rel (types 'type) (list x ...)))])))

(define-syntax-rule (idb (f x ...) e)
  (begin (define (f x ...) e)
         (hash-set! meta 'r f)))

(define-syntax-rule (def (f x ...) e)
  (begin (define (f x ...) e)
         (hash-set! symbol->fun 'f f)
         (hash-set! fun->symbol f 'f)
         (hash-set! fun->type f (list (hash-ref var->type x) ...))))

(define-syntax-rule (stratum (fun s) (λ (x ...) e))
  (begin
    (define (fun s)
      (λ (x ...)
        (define args (make-hash (list (cons 'x x) ...)))
        (define (punctuate p)
          (match p
            [(? symbol?) (hash-ref args p p)]
            [(cons o xs) (if (eq? o 's)
                             (apply s (map punctuate xs))
                             (cons o (map punctuate xs)))]
            [_ p]))
        (punctuate 'e)))
    (hash-set! meta 'fun (cons fun (list 'x ...)))))

(define (e->s p) (exp->struct p symbol->var symbol->rel symbol->fun))
(define (s->e p) (struct->exp p var->symbol rel->symbol fun->symbol))
(define (normalize e) (semiring e))
(define (extract rw e) (semiring e "extract" rw))

(define (optimize)
  (define g-f-r
    (let* ([f (car (hash-ref meta 'f))]
           [g (car (hash-ref meta 'g))]
           [xs (cdr (hash-ref meta 'g))]
           [r (hash-ref meta 'r)]
           [p (apply (g (f r)) xs)])
      (e->s (normalize p))))


  (define g-r
    (let* ([r (hash-ref meta 'r)]
           [g (car (hash-ref meta 'g))]
           [xs (cdr (hash-ref meta 'g))])
      (normalize (apply (g r) xs))))

  (define g-r=>s
    (let ([xs (cdr (hash-ref meta 'g))]
          [lhs (make-pattern g-r)])
      (~a lhs `(S ,@(map make-pattern xs)) #:separator "=>")))

  (define r (compose1 e->s (hash-ref meta 'r)))

  (define h-g-r
    (gen-grammar var->type type->var type->rel fun->type
                 (list op-+ op-* op--)
                 g-f-r (e->s g-r)))

  (define M
    (synthesize
     #:forall (append (hash-values symbol->rel)
                      (hash-values symbol->var)
                      #;(hash-values symbol->fun)
                      (list sum inv))
     #:guarantee (assert (eq? (interpret h-g-r) (interpret g-f-r)))))

  (extract g-r=>s (s->e (evaluate h-g-r M))))
