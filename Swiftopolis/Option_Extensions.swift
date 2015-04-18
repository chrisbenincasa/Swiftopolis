//
//  Option_Extensions.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/13/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

extension Optional {
    func isEmpty() -> Bool {
        return self == nil
    }
    
    func isDefined() -> Bool {
        return !isEmpty()
    }
    
    func get() -> T {
        return self!
    }
    
    func getOrElse(@autoclosure f:  () -> T) -> T {
        switch (self) {
        case let .Some(x): return x
        case .None: return f()
        }
    }
    
    func foreach(f: T -> Void) -> Void {
        switch self {
        case .Some(let x):
            f(x)
            return
        case .None: return
        }
    }
    
    func flatMap<Z>(f: T -> Z?) -> Z? {
        switch self {
        case .Some(let a):
            return f(a)
        case .None:
            return .None
        }
    }
    
    func toArray() -> Array<T> {
        switch self {
        case .Some(let a): return [T](arrayLiteral: a)
        case .None: return []
        }
    }
}
