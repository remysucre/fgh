use egg::*;
use std::collections::HashSet;
use std::cmp::Ordering;

use crate::lang::*;
use crate::EGraph;

#[derive(Default, Clone)]
pub struct SemiringAnalysis;

// Metadata for each class
#[derive(Debug, PartialEq, Eq)]
pub struct Data {
    // Set of free variables by their class ID
    pub free: HashSet<Symbol>,
    pub constant: Option<Semiring>,
}

impl Analysis<Semiring> for SemiringAnalysis {
    type Data = Data;
    // fn merge(&self, to: &mut Data, from: Data) -> Option<Ordering> {
    //     if *to == from {
    //         false
    //     } else {
    //         // The free vars may differ due to constant folding
    //         to.free.retain(|i| from.free.contains(i));

    //         // Merged classes must agree on the constant value,
    //         // if both have one.
    //         if let Some(c_from) = from.constant {
    //             if let Some(c_to) = &to.constant {
    //                 assert_eq!(&c_from, c_to, "merging classes with different constants");
    //             } else {
    //                 to.constant = Some(c_from);
    //             }
    //         }
    //         true
    //     }
    // }

    fn merge(&self, to: &mut Data, from: Data) -> Option<Ordering> {
        let before_len = to.free.len();
        // to.free.extend(from.free);
        to.free.retain(|i| from.free.contains(i));
        let did_change = before_len != to.free.len();
        if to.constant.is_none() && from.constant.is_some() {
            to.constant = from.constant;
            None
        } else if did_change {
            None
        } else {
            Some(Ordering::Greater)
        }
    }

    fn make(egraph: &EGraph, enode: &Semiring) -> Data {
        let fvs = |i: &Id| egraph[*i].data.free.iter().copied();
        let mut free = HashSet::default();
        match enode {
            Semiring::Symbol(v) => {
                free.insert(*v);
            }
            Semiring::Let([v, a, b]) => {
                free.extend(fvs(b));
                // NOTE only do this if v free in b?
                if let Some(v) = fvs(v).next() {
                    free.remove(&v);
                }
                free.extend(fvs(a));
            }
            Semiring::Sum([v, a]) => {
                free.extend(fvs(a));
                if let Some(v) = fvs(v).next() {
                    free.remove(&v);
                }
            }
            Semiring::Rel(xs) =>
                for x in xs[1..].iter() {
                    free.extend(fvs(x));
                }
            Semiring::Other(_, xs) => {
                for x in xs {
                    free.extend(fvs(x));
                }
            }
            _ => enode.for_each(|c| free.extend(&egraph[c].data.free)),
        }
        let constant = eval(egraph, enode);
        Data { free, constant }
    }

    fn modify(egraph: &mut EGraph, id: Id) {
        if let Some(c) = egraph[id].data.constant.clone() {
            let const_id = egraph.add(c);
            egraph.union(id, const_id);
        }
    }
    fn pre_union(_egraph: &egg::EGraph<Semiring, Self>, _id1: Id, _id2: Id) {}
}

fn eval(egraph: &EGraph, enode: &Semiring) -> Option<Semiring> {
    let x = |i: &Id| egraph[*i].data.constant.clone();
    match enode {
        Semiring::Num(n) => Some(Semiring::Num(*n)),
        Semiring::Add([a, b]) => Some(Semiring::Num(x(a)?.num()? + x(b)?.num()?)),
        Semiring::Min([a, b]) => Some(Semiring::Num(x(a)?.num()? - x(b)?.num()?)),
        Semiring::Mul([a, b]) => Some(Semiring::Num(x(a)?.num()? * x(b)?.num()?)),
        _ => None,
    }
}
