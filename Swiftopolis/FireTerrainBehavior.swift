//
//  FireTerrainBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class FireTerrainBehavior: TileBehavior {
    private let dx = [0, 1, 0, -1]
    private let dy = [-1, 0, 1, 0]
    
    override func apply() {
        for i in 0...3 {
            if arc4random_uniform(8) == 0 {
                let xtem = self.xPos + dx[i]
                let ytem = self.yPos + dy[i]
                
                if !city.withinBounds(x: xtem, y: ytem) {
                    continue
                }
                
                let tileNumber = city.getTile(x: xtem, y: ytem)
                let tile = Tiles.get(Int(tileNumber))
                if TileConstants.isCombustable(tileNumber) {
                    if TileConstants.isZoneCenter(tileNumber) {
                        city.killZone(x: xtem, y: ytem)
                        if (tileNumber > 128) {
                            city.makeExplosion(x: xtem, y: ytem)
                        }
                    }
                    
                    city.setTile(x: xtem, y: ytem, tile: TileConstants.FIRE)
                }
            }
        }
    }
}
