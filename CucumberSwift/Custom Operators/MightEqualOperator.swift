import Foundation

precedencegroup MightBePrecedence {
    lowerThan: CastingPrecedence
    associativity: left
}

infix operator ?= : MightBePrecedence
func ?=<T> ( lhs: inout T, rhs: T?) {
    if let r = rhs {
        lhs = r
    }
}

