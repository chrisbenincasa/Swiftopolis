//
//  Option_Extensions.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/13/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

extension Optional {
    func getOrElse(f: @autoclosure () -> T) -> T {
        switch (self) {
        case let .Some(x): return x
        case .None: return f()
        }
    }    
}
