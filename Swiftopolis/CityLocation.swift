//
//  CityLocation.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class CityLocation : Equatable, Printable {
    private(set) var x: Int
    private(set) var y: Int
    
    var description: String {
        return "CityLocation(x: \(x), y: \(y))"
    }
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    func setCoordinates(#x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    func setX(x: Int) {
        self.x = x
    }
    
    func setY(y: Int) {
        self.y = y
    }
    
    func equalsPoint(point: CGPoint) -> Bool {
        return self.x == Int(point.x) && self.y == Int(point.y)
    }
}

func ==(lhs: CityLocation, rhs: CityLocation) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
