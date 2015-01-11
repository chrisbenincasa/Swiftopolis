//
//  RadioactiveTerrainBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class RadioactiveTerrainBehavior: TileBehavior { 
    override func apply() {
        if arc4random_uniform(4096) == 0 {
            city.setTile(x: self.xPos, y: self.yPos, tile: TileConstants.DIRT)
        }
        
        return
    }
}
