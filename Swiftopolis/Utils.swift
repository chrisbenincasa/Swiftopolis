//
//  Utils.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/11/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class Utils {

    class func initializeArray<T>(inout a: Array<T>, size: Int, value: T) {
        a.removeAll(keepCapacity: true)
        a = Array<T>(count: size, repeatedValue: value)
    }
    
    class func initializeMatrix<T>(inout a: Array<Array<T>>, width: Int, height: Int, value: T) {
        a.removeAll(keepCapacity: true)
        
        for _ in 0...width - 1 {
            var arr = Array<T>()
            initializeArray(&arr, size: height, value: value)
            a.append(arr)
        }
    }
}