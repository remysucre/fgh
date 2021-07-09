#lang rosette

(require rosette/lib/synthax) ; provides `choose*`
(require rosette/lib/angelic) ; provides `choose*`

(require "ops.rkt")
(require "util.rkt")

(provide (all-defined-out))

(define (gen-grammar var->type type->var type->rel fun->type ops p g)

  (define env (make-hash))

  (define (sk g)
    (match g
      [(op-sum v e) (begin (hash-clear! env) (sk e))]
      [(? procedure? g) g]
      [(? constant? g) (hash-ref! env g (λ () (??var (hash-ref var->type g))))]
      [_ (fix sk g)]))

  (define (rels p)
    (match p
      [(op-I (op-rel r _)) (if (member r (symbolics g)) 1 p)]
      [(op-* x y) (op-* (rels x) (rels y))]
      [_ 1]))

  (define (sketch p g)
    (match p
      [(op-+ x y)
       (match g
         [(op-+ a b) (op-+ (sketch x a) (sketch y b))]
         [_ (op-+ (sketch x g) (sketch y g))])]
      [(op-sum x e) (op-sum x (sketch e g))]
      [(op-* x y) (op-* (op-* (rels p) (??factor 0)) (sk g))]
      [_ p]))

  (define (??var t) (apply choose* (hash-ref type->var t)))
  (define (??vars ts)
    (let ([vss (apply cartesian-product (map (curry hash-ref type->var) ts))])
      (apply choose* (filter (negate check-duplicates) vss))))

  (define ws (hash-ref type->var 'int? (list)))
  (define (??o) (apply choose* ops))

  (define (??rel)
    (define (gen-rel tr)
      (match tr [(cons (cons ts t) rs)
                 (let ([r (op-rel (apply choose* rs) (??vars ts))])
                   (match t ['bool? (op-I r)] ['int? r]))]))
    (map gen-rel (hash->list type->rel)))

  (define (??fun)
    (define (gen-fun ft)
      (match ft [(cons f ts)
                 (let ([vs (map ??var ts)])
                   (op f vs))]))
    (map gen-fun (hash->list fun->type)))

  (define (??factor depth)
    (if (= 0 depth)
        (apply choose* (append ws (??rel) (??fun) (list 0 1)))
        ((??o) (??factor (- depth 1)) (??factor (- depth 1)))))

  (sketch p g))
