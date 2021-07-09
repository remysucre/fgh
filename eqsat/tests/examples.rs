use egg::*;
use semiring::rewrites::*;

fn check_eq(x: &str, y: &str) {
    let _ = env_logger::builder().is_test(true).try_init();
    let runner = Runner::default()
        .with_iter_limit(1000)
        .with_node_limit(1000_000)
        .with_time_limit(std::time::Duration::from_secs(60))
        // .with_scheduler(
        //     BackoffScheduler::default()
        //         .rule_match_limit("nat", 1)
        //         .rule_match_limit("exclusion", 1)
        //         .rule_match_limit("l-49", 1)
        //         .rule_match_limit("l-51", 1)
        //         .rule_match_limit("l-52", 1)
        //         .rule_match_limit("l-53", 1)
        //         .rule_ban_length("nat", 50)
        //         .rule_ban_length("exclusion", 50)
        //         .rule_ban_length("l-49", 50)
        //         .rule_ban_length("l-51", 50)
        //         .rule_ban_length("l-52", 50)
        //         .rule_ban_length("l-53", 50)
        // )
        .with_expr(&x.parse().unwrap())
        .with_expr(&y.parse().unwrap())
        .with_hook(|runner| {
            let lhs = runner.egraph.find(runner.roots[0]);
            let rhs = runner.egraph.find(runner.roots[1]);
            if lhs == rhs {
                Err("qed".to_string())
            } else {
                Ok(())
            }
        })
        .run(&elim_sums());
    let lhs = runner.roots[0];
    let rhs = runner.roots[1];
    runner.print_report();
    assert_eq!(runner.egraph.find(lhs), runner.egraph.find(rhs))
}

// #[test]
// fn apsp() {
//     check_eq(
//         "
// (sum (var w)
//      (* (+ (rel E (var x) (var z) (var w))
//            (sum (var y)
//                 (sum (var w1)
//                      (sum (var w2)
//                           (* (* (rel R (var x) (var y) (var w1))
//                                 (rel E (var y) (var z) (var w2)))
//                              (I (= (var w) (* (var w1) (var w2)))))))))
//         (var w)))
// ",
//         "
// (+ (sum (var w)
//         (* (var w)
//            (rel E (var x) (var z) (var w))))
//    (sum (var y)
//         (* (sum (var w1)
//                 (* (var w1)
//                    (rel R (var x) (var y) (var w1))))
//            (sum (var w2)
//                 (* (var w2)
//                    (rel E (var y) (var z) (var w2)))))))",
//     )
// }

// test_fn! {
//     apsp_sat, elim_sums(),
//     runner = Runner::default()
//         .with_iter_limit(60),
//         "
// (sum (var w)
//      (* (+ (rel E (var x) (var z) (var w))
//            (sum (var y)
//                 (sum (var w1)
//                      (sum (var w2)
//                           (* (* (rel R (var x) (var y) (var w1))
//                                 (rel E (var y) (var z) (var w2)))
//                              (I (= (var w) (* (var w1) (var w2)))))))))
//         (var w)))
// " =>
//         "
// (+ (sum (var w)
//         (* (var w)
//            (rel E (var x) (var z) (var w))))
//    (sum (var y)
//         (* (rel S (var x) (var y))
//            (sum (var w2)
//                 (* (var w2)
//                    (rel E (var y) (var z) (var w2)))))))
// "
// }

// #[test]
// fn running_total() {
//     check_eq(
//         "
// (sum (var w)
//      (sum (var j)
//           (* (* (var w) (* (I (<= 1 (var j)))
//                            (I (<= (var j) (var t)))))
//              (+ (* (I (= (var t) (var j)))
//                    (rel v (var j) (var w)))
//                 (* (rel R (- (var t) 1) (var j) (var w))
//                    (* (I (< (var j) (var t)))
//                       (I (> (var t) 1))))))))
// ",
//         "
// (+ (* (I (> (var t) 1))
//       (sum (var j)
//            (sum (var w)
//                 (* (* (rel R (- (var t) 1) (var j) (var w))
//                       (var w))
//                    (* (I (<= (var j) (- (var t) 1)))
//                       (I (<= 1 (var j))))))))
//    (sum (var j)
//         (sum (var w)
//              (* (* (rel v (var j) (var w))
//                    (var w))
//                 (* (I (= (var t) (var j)))
//                    (I (<= 1 (var j))))))))",
//     )
// }

// test_fn! {
//     running_total_sat, rules(),
//     runner = Runner::default()
//         .with_node_limit(500_000)
//         .with_iter_limit(60),
//         "
// (sum (var w)
//      (sum (var j)
//           (* (* (var w) (* (I (<= 1 (var j)))
//                            (I (<= (var j) (var t)))))
//              (+ (* (I (= (var t) (var j)))
//                    (rel v (var j) (var w)))
//                 (* (rel R (- (var t) 1) (var j) (var w))
//                    (* (I (< (var j) (var t)))
//                       (I (> (var t) 1))))))))
// " =>
//         "
// (+ (* (I (> (var t) 1))
//       (sum (var j)
//            (sum (var w)
//                 (* (* (rel R (- (var t) 1) (var j) (var w))
//                       (var w))
//                    (* (I (<= (var j) (- (var t) 1)))
//                       (I (<= 1 (var j))))))))
//    (sum (var j)
//         (sum (var w)
//              (* (* (rel v (var j) (var w))
//                    (var w))
//                 (* (I (= (var t) (var j)))
//                    (I (<= 1 (var j))))))))"
// }
