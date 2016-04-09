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
    
    func get() -> Wrapped {
        return self!
    }
    
    func getOrElse(@autoclosure f: () -> Wrapped) -> Wrapped {
        switch (self) {
        case let .Some(x): return x
        case .None: return f()
        }
    }
    
    func foreach(f: Wrapped -> Void) -> Void {
        switch self {
        case .Some(let x):
            f(x)
            return
        case .None: return
        }
    }
    
    func flatMap<Z>(f: Wrapped -> Z?) -> Z? {
        switch self {
        case .Some(let a):
            return f(a)
        case .None:
            return .None
        }
    }
    
    func exists(@noescape f: Wrapped -> Bool) -> Bool {
        return self.map(f).getOrElse(false)
    }
    
    func toArray() -> Array<Wrapped> {
        switch self {
        case .Some(let a): return [Wrapped](arrayLiteral: a)
        case .None: return []
        }
    }
}

func identity<T>(i: T) -> T { return i }
