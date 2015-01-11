//
//  CityLocation.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class CityLocation {
    private(set) var x: Int
    private(set) var y: Int
    
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
}
