use inv::{*, lang::*, inter::*};

use egg::*;

use std::collections::HashSet;
use std::iter::FromIterator;

// init: tc(x,y) = 0(x,y);
// loop: tc(x,y) = sum z . tc(x,z) * e(z,y)
// inv:  tc(x,z) * e(z,y) = e(x,z) * tc(z,y)

// sum z . tc(x,z) * e(z,w)
// sum z . (sum y . tc(x,y) * e(y,z)) * e(z,w)
// sum y z . tc(x,y) * e(y,z) * e(z,w)
// sum y z . e(x,y) * tc(y,z) * e(z,w)
//
// sum y . e(x,y) * tc(y,z)
// sum y . e(x,y) * (sum z . tc(y,z) * e(z,w))
// sum y z . e(x,y) * tc(y,z) * e(z,w)

// Constraints:
// e = t * e
// e (t * x) = t * e (t * x)
//
// init: tc = 0
// loop: tc = e + e tc
// inv: tc = t * tc

pub fn main() {
    // declare variables
    let vs: HashSet<&str> = HashSet::from_iter(
        vec!["tc"].into_iter()
    );

    // initial state
    let ini = vec![
        ("tc", "0"),
    ];

    // loop body
    let p = vec![
        ("tc", "(+ e (* e tc))"),
    ];

    // math axioms and initialization
    let mut rls = rules();
    rls.extend(init(&ini));

    let mut e = Runner::default()
        .with_expr(&"(. t tc)".parse().unwrap())
        .with_expr(&"(+ e (* (. tc t) e))".parse().unwrap())
        .with_expr(&"(+ e (* tc e))".parse().unwrap())
        .with_expr(&"(+ e (* e tc))".parse().unwrap())
        .with_scheduler(
            BackoffScheduler::default()
                .rule_match_limit("add-0", 2)
                .rule_match_limit("add-0-rev", 2)
                .rule_match_limit("mul-x-0", 2)
                .rule_match_limit("mul-0-x", 2)
                .rule_ban_length("add-0", 100)
                .rule_ban_length("add-0-rev", 100)
                .rule_ban_length("mul-x-0", 100)
                .rule_ban_length("mul-0-x", 100)
        )
        .with_iter_limit(3)
        .run(&rls)
        .egraph;

    // println!("size: {}", e.total_size());
    // e.dot().to_png("init.png").unwrap();

    for _n in 1..5 {

        let mut rls = rules();
        rls.extend(step(&p));

        let curr_e = Runner::default()
            .with_egraph(e.clone())
            .with_expr(&"(. step_tc t)".parse().unwrap())
            // E + (E (TC * T)) * T
            .with_expr(&"(+ e (. t (* e (. tc t))))".parse().unwrap())
            .with_expr(&"(+ e (* step_tc e))".parse().unwrap())
            .with_expr(&"(+ e (* e step_tc))".parse().unwrap())
            .with_scheduler(
                BackoffScheduler::default()
                    .rule_match_limit("add-0", 2)
                    .rule_match_limit("add-0-rev", 2)
                    .rule_match_limit("mul-x-0", 2)
                    .rule_match_limit("mul-0-x", 2)
                    .rule_ban_length("add-0", 100)
                    .rule_ban_length("add-0-rev", 100)
                    .rule_ban_length("mul-x-0", 100)
                    .rule_ban_length("mul-0-x", 100)
            )
            .with_iter_limit(1)
            .run(&rls)
            .egraph;

        let rn_e = &rename(curr_e, &vs);
        // rn_e.dot().to_png(format!("step_{}.5.png", n - 1)).unwrap();

        e = intersect(&e, &rn_e, ());

        // e.dot().to_png(format!("step_{}.png", n)).unwrap();
    }
    // e.dot().to_png("inv.png").unwrap();
    println!("{}",e.total_size());
}
