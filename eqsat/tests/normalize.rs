use egg::*;
use semiring::lang::*;
use semiring::rewrites::*;

fn norm(e: &str) -> RecExpr<Semiring> {
    let start = e.parse().unwrap();
    let runner = Runner::default().with_expr(&start).run(&elim_sums());
    let (egraph, root) = (runner.egraph, runner.roots[0]);

    let mut extractor = Extractor::new(&egraph, VarCost);
    let (_, best) = extractor.find_best(root);

    let normalize_runner = Runner::default().with_expr(&best).run(&normalize());
    let (egraph, root) = (normalize_runner.egraph, normalize_runner.roots[0]);
    let mut extractor = Extractor::new(&egraph, AstSize);
    let (_, best) = extractor.find_best(root);
    best.pretty(40).parse().unwrap()
}

#[test]
fn apsp_norm() {
    let e = norm(
        &"(sum w
         (* (+ (I (rel E (var x) (var z) (var w)))
               (sum y
                    (sum w1
                         (sum w2
                              (* (* (I (rel R (var x) (var y) (var w1)))
                                    (I (rel E (var y) (var z) (var w2))))
                                 (I (= (var w) (* (var w1) (var w2)))))))))
            (var w)))",
    );
    assert_eq!(
        e,
        "(+
  (weight (var w) (var x) (var z))
  (sum y
    (sum w1
      (* (weight (var w2) (var y) (var z))
        (* (var w1)
          (I (rel R (var x) (var y) (var w1))))))))"
            .parse()
            .unwrap()
    )
}

#[test]
fn centrality_norm() {
    let e = norm(
        &"(sum t
     (* (I (= (rel D (var s) (var t))
              (+ (rel D (var s) (var v))
                 (rel D (var v) (var t)))))
        (/ (* (rel sigma (var s) (var v))
              (+ (I (rel E (var v) (var t)))
                 (sum u (* (* (rel sigma (var u) (var t)) (I (rel E (var v) (var u))))
                           (I (= (rel D (var v) (var t))
                                 (+ 1 (rel D (var u) (var t)))))))))
           (rel sigma (var s) (var t)))))",
    );
    assert_eq!(
        e,
        "(+
  (sum t
    (* (I (= (rel D (var s) (var t))
          (+ (rel D (var s) (var v))
            (rel D (var v) (var t)))))
      (* (inv (rel sigma (var s) (var t)))
        (* (rel sigma (var s) (var v))
          (I (rel E (var v) (var t)))))))
  (sum t
    (sum u
      (* (I (= (rel D (var s) (var t))
            (+ (rel D (var s) (var v))
              (rel D (var v) (var t)))))
        (* (inv (rel sigma (var s) (var t)))
          (* (rel sigma (var s) (var v))
            (* (* (rel sigma (var u) (var t))
                (I (rel E (var v) (var u))))
              (I (= (rel D (var v) (var t))
                  (+ 1 (rel D (var u) (var t))))))))))))"
            .parse()
            .unwrap()
    )
}

#[test]
fn window_norm() {
    let e = norm(
        &"(- (sum w
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
                      (I (> (- (var t) (var k)) 1)))))))))",
    );
    assert_eq!(
        e,
        "(-
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
              (I (> (- (var t) (var k)) 1)))))))))"
            .parse()
            .unwrap()
    )
}
