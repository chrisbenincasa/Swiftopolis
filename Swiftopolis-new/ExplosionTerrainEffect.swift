//
//  ExplosionTerrainEffect.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/6/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class ExplosionTerrainEffect: TileBehavior {

    override func apply() {
        city.setTile(x: xPos, y: yPos, tile: TileConstants.RUBBLE + UInt16(arc4random_uniform(4)))
    }
}
