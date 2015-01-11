//
//  FloodTerrainBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class FloodTerrainBehavior: TileBehavior {    
    private let dx = [0, 1, 0, -1]
    private let dy = [-1, 0, 1, 0]
    
    override func apply() {
        // if city.floodCount != 0
        for i in 0...3 {
            if arc4random_uniform(8) == 0 {
                let xx = self.xPos + dx[i]
                let yy = self.yPos + dy[i]
                if !city.withinBounds(x: xx, y: yy) {
                    continue
                }
                
                let tileNumber = city.getTile(x: xx, y: yy)
                if TileConstants.isCombustable(tileNumber) ||
                    tileNumber == TileConstants.DIRT ||
                    (tileNumber == TileConstants.WOODS5 && tileNumber < TileConstants.FLOOD) {
                        
                        if TileConstants.isZoneCenter(tileNumber) {
                            city.killZone(x: xx, y: yy)
                        }
                        
                        city.setTile(x: xx, y: yy, tile: TileConstants.FLOOD + UInt16(arc4random_uniform(3)))
                }
            }
        }
        // else
        // random(16) == 0
        // city.setTile(xx, yy, DIRT)
    }
}
