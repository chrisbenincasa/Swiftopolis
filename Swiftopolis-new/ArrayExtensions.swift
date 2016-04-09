//
//  ArrayExtensions.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

extension Array {
    var nonEmpty: Bool {
        return !self.isEmpty
    }
    
    func foreach(f: (element: Element) -> Void) {
        for ele in self {
            f(element: ele)
        }
    }
    
    func flatMap<U>(f: Element -> [U]) -> [U] {
        var ret: [U] = []
        self.foreach { (element) -> Void in
            ret.appendContentsOf(f(element))
        }
        
        return ret
    }
    
    mutating func pop() -> Element {
        return self.removeAtIndex(0)
    }
}
