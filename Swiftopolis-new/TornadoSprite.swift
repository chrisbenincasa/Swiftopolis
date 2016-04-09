//
//  TornadoSprite.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/12/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class TornadoSprite: Sprite {
    convenience init(city: City) {
        self.init(city: city, kind: .Tornado)
    }
    
    override func moveImpl() {
        
    }
}
