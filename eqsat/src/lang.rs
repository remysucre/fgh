use egg::*;

define_language! {
    pub enum Semiring {
        // A bare number is a literal
        Num(i32),

        // All variables are tagged with var
        // to distinguish from relations
        // e.g. (var x)
        // "var" = Var(Id),

        // Relations are tagged with rel
        // e.g. (rel R (var x) (var y))
        "rel" = Rel(Box<[Id]>),

        "+" = Add([Id; 2]),
        "-" = Min([Id; 2]),
        "*" = Mul([Id; 2]),

        // (sum x e) not (sum (var x) e)
        "sum" = Sum([Id; 2]),

        // (let x e) not (let (var x) e)
        "let" = Let([Id; 3]),

        // Indicator, i.e. (I true) = 1, (I false) = 0
        "I" = Ind(Id),

        "<" = Lt([Id; 2]),
        "<=" = Leq([Id; 2]),
        ">" = Gt([Id; 2]),
        ">=" = Geq([Id; 2]),
        "=" = Eq([Id; 2]),

        Symbol(egg::Symbol),

        // Fallback to arbitrary "UDF"
        Other(Symbol, Vec<Id>),
    }
}

// Extract literal numbers if any
impl Semiring {
    pub fn num(&self) -> Option<i32> {
        match self {
            Semiring::Num(n) => Some(*n),
            _ => None,
        }
    }
}

// TODO could optimze for summation depth too
pub struct VarCost;

impl CostFunction<Semiring> for VarCost {
    type Cost = u64;
    fn cost<C>(&mut self, enode: &Semiring, mut costs: C) -> Self::Cost
    where
        C: FnMut(Id) -> Self::Cost,
    {
        let op_cost = match enode {
            Semiring::Sum(_) => 1000,
            _ => 0,
        };
        enode.fold(op_cost, |sum, id| sum + costs(id))
    }
}

pub struct GCost;

impl CostFunction<Semiring> for GCost {
    type Cost = u64;
    fn cost<C>(&mut self, enode: &Semiring, mut costs: C) -> Self::Cost
    where
        C: FnMut(Id) -> Self::Cost,
    {
        let op_cost = match enode {
            Semiring::Symbol(s) => {
                if s == &Symbol::from("fun-g") {
                    0
                } else {
                    100
                }
            }
            _ => 100,
        };
        enode.fold(op_cost, |sum, id| sum + costs(id))
    }
}
