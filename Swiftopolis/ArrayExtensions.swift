//
//  ArrayExtensions.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

extension Array {
    func foreach(f: (element: T) -> Void) {
        for ele in self {
            f(element: ele)
        }
    }
    
    func flatMap<U>(f: T -> [U]) -> [U] {
        var ret: [U] = []
        self.foreach { (element) -> Void in
            ret.extend(f(element))
        }
        
        return ret
    }
}
