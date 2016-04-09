//
//  MonsterSprite.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/12/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class MonsterSprite: Sprite {
    var soundCount: Int = 0
    var wantsToReturnHome: Bool = false
    private(set) var destination: CityLocation?
    
    convenience init(city: City) {
        self.init(city: city, kind: .Monster)
    }
    
    func setDestination(location: CityLocation) {
        self.destination = location
    }
}
