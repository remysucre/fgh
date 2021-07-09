;; APSP
(sum w
     (* (+ (rel E (var x) (var z) (var w))
           (sum y
                (sum w1
                     (sum w2
                          (* (* (rel R (var x) (var y) (var w1))
                                (rel E (var y) (var z) (var w2)))
                             (I (= (var w) (* (var w1) (var w2)))))))))
        (var w)))

;; out
(+
  (weight (var w) (var x) (var z))
  (sum y
    (sum w1
      (* (weight (var w2) (var y) (var z))
        (* (var w1)
          (I (rel R (var x) (var y) (var w1))))))))

;; window
(- (sum w
     (sum j
          (* (* (var w) (* (I (<= 1 (var j)))
                           (I (<= (var j) (var t)))))
             (+ (* (I (= (var t) (var j)))
                   (I (rel v (var j) (var w))))
                (* (I (rel R (- (var t) 1) (var j) (var w)))
                   (* (I (< (var j) (var t)))
                      (I (> (var t) 1))))))))
   (sum w
     (sum j
          (* (* (var w) (* (I (<= 1 (var j)))
                           (I (<= (var j) (- (var t) (var k))))))
             (+ (* (I (= (- (var t) (var k)) (var j)))
                   (I (rel v (var j) (var w))))
                (* (I (rel R (- (- (var t) (var k)) 1) (var j) (var w)))
                   (* (I (< (var j) (- (var t) (var k))))
                      (I (> (- (var t) (var k)) 1)))))))))

;; out
(-
  (+
    (sum
      w
      (sum
        j
        (*
          (*
            (var w)
            (*
              (I (<= 1 (var j)))
              (I (<= (var j) (var t)))))
          (*
            (I (= (var j) (var t)))
            (I (rel v (var j) (var w)))))))
    (sum
      w
      (sum
        j
        (*
          (*
            (var w)
            (*
              (I (<= 1 (var j)))
              (I (<= (var j) (var t)))))
          (*
            (I (rel R (- (var t) 1) (var j) (var w)))
            (*
              (I (< (var j) (var t)))
              (I (> (var t) 1))))))))
  (+
    (sum
      w
      (sum
        j
        (*
          (*
            (var w)
            (*
              (I (<= 1 (var j)))
              (I (<= (var j) (- (var t) (var k))))))
          (*
            (I (rel v (var j) (var w)))
            (I (= (var j) (- (var t) (var k))))))))
    (sum
      w
      (sum
        j
        (*
          (*
            (var w)
            (*
              (I (<= 1 (var j)))
              (I (<= (var j) (- (var t) (var k))))))
          (*
            (I (rel
              R
              (- (- (var t) (var k)) 1)
              (var j)
              (var w)))
            (*
              (I (< (var j) (- (var t) (var k))))
              (I (> (- (var t) (var k)) 1)))))))))

;; centrality
(sum t
     (* (I (= (rel D (var s) (var t))
              (+ (rel D (var s) (var v))
                 (rel D (var v) (var t)))))
        (/ (* (rel sigma (var s) (var v))
              (+ (I (rel E (var v) (var t)))
                 (sum u (* (* (rel sigma (var u) (var t)) (I (rel E (var v) (var u))))
                           (I (= (rel D (var v) (var t))
                                 (+ 1 (rel D (var u) (var t)))))))))
           (rel sigma (var s) (var t)))))

;; out
(+
  (sum
    t
    (*
      (I
        (=
          (rel D (var s) (var t))
          (+
            (rel D (var s) (var v))
            (rel D (var v) (var t)))))
      (*
        (inv (rel sigma (var s) (var t)))
        (*
          (rel sigma (var s) (var v))
          (I (rel E (var v) (var t)))))))
  (sum
    t
    (sum
      u
      (*
        (I
          (=
            (rel D (var s) (var t))
            (+
              (rel D (var s) (var v))
              (rel D (var v) (var t)))))
        (*
          (inv (rel sigma (var s) (var t)))
          (*
            (rel sigma (var s) (var v))
            (*
              (*
                (rel sigma (var u) (var t))
                (I (rel E (var v) (var u))))
              (I
                (=
                  (rel D (var v) (var t))
                  (+ 1 (rel D (var u) (var t))))))))))))
