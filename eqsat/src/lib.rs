pub mod analysis;
pub mod lang;
pub mod rewrites;

pub type EGraph = egg::EGraph<lang::Semiring, analysis::SemiringAnalysis>;
