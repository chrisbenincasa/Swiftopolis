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
        for y in 0...h - 1 {
            for x in 0...w - 1 {
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
                
                tem[y][x] = z
            }
        }
    }
    
    class func smoothN(inout tem: [[Int]], n: Int = 2) {
//        var tem2 = tem
        for _ in 0...n - 1 {
            smooth(&tem)
        }
        
//        return tem2
    }
    
    class func smoothTerrain(tem: [[Int]]) -> [[Int]] {
        let h = tem.count, w = tem[0].count
        var tem2: [[Int]] = []
        for _ in 0...h {
            tem2.append([Int](count: w, repeatedValue: 0))
        }
        
        for y in 0...h - 1 {
            for x in 0...w - 1 {
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
                
                tem2[y][x] = (z / 4) + (tem[y][x] / 2)
            }
        }
        
        return tem2
    }
    
    class func smoothFirePoliceMap(tem: [[Int]]) -> [[Int]] {
        let h = tem.count, w = tem[0].count
        var tem2: [[Int]] = []
        for _ in 0...h {
            tem2.append([Int](count: w, repeatedValue: 0))
        }
        
        for y in 0...h - 1 {
            for x in 0...w - 1 {
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
                tem2[y][x] = z / 2
            }
        }
        
        return tem2
    }
}
