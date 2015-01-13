//
//  Sprite.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/11/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa
import SpriteKit

class Sprite {
    private var city: City
    private var sprite:  SKSpriteNode?
    private(set) var cityLocation: CityLocation?
    internal(set) var kind: SpriteKind
    private(set) var remainingTurns: Int = 0

    required init(city: City, kind: SpriteKind) {
        self.city = city
        self.kind = kind
    }
    
    convenience init(city: City, kind: SpriteKind, sprite: SKSpriteNode!) {
        self.init(city: city, kind: kind)
        self.sprite = sprite
    }
    
    func setCityLocation(cityLocation: CityLocation!) {
        self.cityLocation = cityLocation
    }
    
    func setRemainingTurns(turns: Int) {
        self.remainingTurns = turns
    }
    
    func move() {
        self.moveImpl()
    }
    
    func moveImpl() {
        
    }
}

enum SpriteKind {
    case None, God, Tornado, Monster
}
