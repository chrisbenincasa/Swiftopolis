//
//  Smoothers.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/10/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class Smoothers {

    class func smooth(inout tem: [[Int]]) {
        let h = tem.count, w = tem[0].count
        var i = 0
        let start = NSDate()
        for var y = 0; y < h; y++ {
            for var x = 0; x < w; x++ {
                var z = tem[y][x]
                if x > 0 {
                    z += tem[y][x - 1]
                }
                
                if x + 1 < w {
                    z += tem[y][x + 1]
                }
                
                if y > 0 {
                    z += tem[y - 1][x]
                }
                
                if y + 1 < h {
                    z += tem[y + 1][x]
                }
                
                z /= 4
                
                if z > 255 {
                    z = 255
                }
                
                i++
                tem[y][x] = z
            }
        }
        
        let timeInterval: Double = NSDate().timeIntervalSinceDate(start)
//        println("smooth (\(i) iterations) took \(timeInterval) seconds");
    }
    
    class func smoothN(inout tem: [[Int]], n: Int = 2) {
        for var i = 0; i < n; i++ {
            smooth(&tem)
        }
    }
    
    class func smoothTerrain(inout tem: [[Int]]) {
        let h = tem.count, w = tem[0].count
        
        for var y = 0; y < h; y++ {
            for var x = 0; x < w; x++ {
                var z = tem[y][x]
                if x > 0 {
                    z += tem[y][x - 1]
                }
                
                if x + 1 < w {
                    z += tem[y][x + 1]
                }
                
                if y > 0 {
                    z += tem[y - 1][x]
                }
                
                if y + 1 < h {
                    z += tem[y + 1][x]
                }
            }
        }
    }
    
    class func smoothFirePoliceMap(inout tem: [[Int]]) {
        let h = tem.count, w = tem[0].count
        
        for var y = 0; y < h; y++ {
            for var x = 0; x < w; x++ {
                var z = 0
                if x > 0 {
                    z += tem[y][x - 1]
                }
                
                if x + 1 < w {
                    z += tem[y][x + 1]
                }
                
                if y > 0 {
                    z += tem[y - 1][x]
                }
                
                if y + 1 < h {
                    z += tem[y + 1][x]
                }
                
                z = (z / 4) + tem[y][x]
                tem[y][x] = z / 2
            }
        }
    }
}
