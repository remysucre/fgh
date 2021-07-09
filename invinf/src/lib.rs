pub mod lang;
pub mod inter;
use lang::*;

use egg::*;

use std::collections::{HashMap, HashSet};

pub fn init(defs: &[(&str, &str)]) -> Vec<lang::Rewrite> {
    let mut rls = vec![];
    for (x, e) in defs {
        rls.push(
            egg::Rewrite::new(
                format!("init-{}", x), // format!("init-{}", x),
                x.parse::<Pattern<Math>>().unwrap(),
                e.parse::<Pattern<Math>>().unwrap(),
            ).unwrap()
        );
        rls.push(
            egg::Rewrite::new(
                format!("init-{}-rev", x), // format!("init-{}-rev", x),
                e.parse::<Pattern<Math>>().unwrap(),
                x.parse::<Pattern<Math>>().unwrap(),
            ).unwrap()
        );
    }
    rls
}

pub fn step(defs: &[(&str, &str)]) -> Vec<lang::Rewrite> {
    let mut rls = vec![];
    for (x, e) in defs {
        rls.push(
            egg::Rewrite::new(
                format!("step-{}", x), // format!("step-{}", x),
                e.parse::<Pattern<Math>>().unwrap(),
                format!("step_{}", x).parse::<Pattern<Math>>().unwrap(),
            ).unwrap()
        );
        rls.push(
            egg::Rewrite::new(
                format!("step-{}-rev", x), // format!("step-{}-rev", x),
                format!("step_{}", x).parse::<Pattern<Math>>().unwrap(),
                e.parse::<Pattern<Math>>().unwrap(),
            ).unwrap()
        );
    }
    rls
}

pub fn rename(e: lang::EGraph, vs: &HashSet<&str>) -> lang::EGraph {
    let mut g = egg::EGraph::new(());
    let mut e_g = HashMap::new();
    loop {
        let mut g_changed = false;
        for c in e.classes() {
            for n in &c.nodes {
                let mut new_node = if let Math::Symbol(x) = n {
                    let x_str = x.as_str();
                    let new_str = match x_str.strip_prefix("step_") {
                        Some(x_s) => x_s.to_string(),
                        None => if vs.contains(&x_str) {
                            format!("prev_{}", x_str)
                        } else {
                            x_str.to_string()
                        },
                    };
                    Math::Symbol(Symbol::from(new_str))
                } else {
                    let mut new_n = n.clone();
                    let ch = new_n.children_mut();
                    let mut skip = false;
                    for i in 0..ch.len() {
                        if let Some(class) = e_g.get(&ch[i]) {
                            ch[i] = *class;
                        } else {
                            skip = true;
                        }
                    }
                    if skip { continue } else { new_n }
                };

                let n_c = g.lookup(&mut new_node).unwrap_or_else(|| {
                    g_changed = true;
                    g.add(new_node)
                });

                if let Some(i) = e_g.get(&c.id) {
                    g.union(*i, n_c);
                } else {
                    e_g.insert(c.id, n_c);
                }
            }
        }
        if !g_changed {
            break;
        }
    }
    g
}

pub fn rn(xs: &[(&str, &str)]) -> Vec<lang::Rewrite> {
    let mut rls = vec![];
    for (x, _) in xs {
        rls.push(
            egg::Rewrite::new(
                format!("rn-{}", x), // format!("rn-{}", x),
                x.parse::<Pattern<Math>>().unwrap(),
                Destroy {
                    e: format!("step_{}", x).parse::<Pattern<Math>>().unwrap(),
                    x: Math::Symbol(x.parse().unwrap()),
                }
            ).unwrap()
        )
    }
    rls
}

// pub fn rn_prev(xs: &[(&str, &str)]) -> Vec<lang::Rewrite> {
//     let mut rls = vec![];
//     for (x, _) in xs {
//         rls.push(
//             egg::Rewrite::new(
//                 format!("rnp-{}", x), format!("rnp-{}", x),
//                 x.parse::<Pattern<Math>>().unwrap(),
//                 Destroy {
//                     e: format!("prev_{}", x).parse::<Pattern<Math>>().unwrap(),
//                     x: Math::Symbol(x.parse().unwrap()),
//                 }
//             ).unwrap()
//         )
//     }
//     rls
// }

pub fn rn_step(xs: &[(&str, &str)]) -> Vec<lang::Rewrite> {
    let mut rls = vec![];
    for (x, _) in xs {
        rls.push(
            egg::Rewrite::new(
                format!("rns-{}", x), // format!("rns-{}", x),
                format!("step_{}", x).parse::<Pattern<Math>>().unwrap(),
                Destroy {
                    e: x.parse::<Pattern<Math>>().unwrap(),
                    x: Math::Symbol(format!("step_{}", x).parse().unwrap()),
                }
            ).unwrap()
        )
    }
    rls
}

pub struct Destroy<A: Applier<Math, ConstantFold>> {
    e: A,
    x: Math,
}

impl<A: Applier<Math, ConstantFold>> Applier<Math, ConstantFold> for Destroy<A> {
    fn apply_one(&self, egraph: &mut lang::EGraph, eclass: Id, subst: &Subst) -> Vec<Id> {
        egraph[eclass].nodes.retain(|node| node != &self.x);
        self.e.apply_one(egraph, eclass, subst)
    }
}
