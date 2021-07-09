#lang rosette
(require "core/lib.rkt")

(decl rel irsg-bf irsg-fb (~> id? bool?))
(decl rel rsg-bf rsg-fb flat up down (~> id? id? bool?))
(decl var x y x1 y1 id?)

(define gf-1 (|| (&& (irsg-bf x) (flat x y))
                 (&& (irsg-bf x)
                     (up x x1)
                     (rsg-fb y1 x1)
                     (down y1 y))))

(define hg-1 (|| (&& (irsg-bf x) (flat x y))
                 (&& (irsg-bf x)
                     (up x x1)
                     (irsg-fb x1)
                     (rsg-fb y1 x1)
                     (down y1 y))))

(define gf-2 (|| (&& (irsg-fb y) (flat x y))
                 (&& (irsg-fb y)
                     (down y1 y)
                     (rsg-bf y1 x1)
                     (up x x1))))

(define hg-2 (|| (&& (irsg-fb y) (flat x y))
                 (&& (irsg-fb y)
                     (down y1 y)
                     (irsg-bf y1)
                     (rsg-bf y1 x1)
                     (up x x1))))

(assert (forall (list x x1)
                (=> (&& (irsg-bf x) (up x x1))
                    (irsg-fb x1))))

(assert (forall (list y y1)
                (=> (&& (irsg-fb y) (down y1 y))
                    (irsg-bf y1))))

(verify (assert (<=> gf-1 hg-1)))
(verify (assert (<=> gf-2 hg-2)))
