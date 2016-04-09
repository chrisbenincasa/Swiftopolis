//
//  RailTerrainBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/6/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class RailTerrainBehavior: TileBehavior {

    override func apply() {
        // city.railTotal++
        // city.generateTrain
        
        if city.budget.roadEffect < 30 &&
            arc4random_uniform(512) == 0 &&
            !TileConstants.isConductive(tile) &&
            city.budget.roadEffect < Int(arc4random_uniform(32)) {

                if TileConstants.isOverWater(tile) {
                    city.setTile(x: xPos, y: yPos, tile: TileConstants.RIVER)
                } else {
                    city.setTile(x: xPos, y: yPos, tile: TileConstants.RUBBLE + UInt16(arc4random_uniform(4)))
                }
        }
    }
}
