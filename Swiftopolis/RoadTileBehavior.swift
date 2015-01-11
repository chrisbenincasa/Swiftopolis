//
//  RoadTileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class RoadTileBehavior: TileBehavior {
    private let trafficDensity = [TileConstants.ROADBASE, TileConstants.LTRFBASE, TileConstants.HTRFBASE]
    
    override func apply() {
        // city.roadTotal++
        
        if self.city.budget.roadEffect < 30 &&
            arc4random_uniform(512) == 0 &&
            TileConstants.isConductive(self.tile) &&
            self.city.budget.roadEffect < Int(arc4random_uniform(32)) {
            
                if TileConstants.isOverWater(self.tile) {
                    city.setTile(x: xPos, y: yPos, tile: TileConstants.RIVER)
                } else {
                    city.setTile(x: xPos, y: yPos, tile: TileConstants.RUBBLE + UInt16(arc4random_uniform(4)))
                }
                
                return
        }
        
        if !TileConstants.isCombustable(self.tile) {
            // city.roadTotal += 4
            if processBridge() {
                return
            }
        }
        
        var density: Int
        if self.tile < TileConstants.LTRFBASE {
            density = 0
        } else if self.tile < TileConstants.HTRFBASE {
            density = 1
        } else {
            // city.roadTotal++
            density = 2
        }
        
        let trafficDensity = city.trafficDensityAtLocation(x: xPos, y: yPos)
        let newLevel = trafficDensity < 64 ? 0 : trafficDensity < 192 ? 1 : 2
        
        if density != newLevel {
            let z = tile - TileConstants.ROADBASE & 15 + self.trafficDensity[newLevel]
            city.setTile(x: xPos, y: yPos, tile: z)
        }
        
        return
    }
    
    private let HORIZONTAL_DX = [-2, 2, -2, -1, 0, 1, 2]
    private let HORIZONTAL_DY = [-1, -1, 0, 0, 0, 0, 0]
    private let HORIZONAL_BRTAB = [TileConstants.HBRDG1, TileConstants.HBRDG3, TileConstants.HBRDG0,
        TileConstants.RIVER, TileConstants.BRWH, TileConstants.RIVER, TileConstants.HBRDG2]
    
    private let HORIZONAL_BRTAB2 = [
        TileConstants.RIVER, TileConstants.RIVER,
        TileConstants.HBRIDGE, TileConstants.HBRIDGE,
        TileConstants.HBRIDGE, TileConstants.HBRIDGE,
        TileConstants.HBRIDGE
    ]
    
    private let VERTICAL_DX = [0,  1,  0,  0,  0,  0,  1]
    private let VERTICAL_DY = [-2, -2, -1,  0,  1,  2,  2]
    
    private let VERTICAL_BRTAB = [
        TileConstants.VBRDG0, TileConstants.VBRDG1,
        TileConstants.RIVER, TileConstants.BRWV,
        TileConstants.RIVER, TileConstants.VBRDG2, TileConstants.VBRDG3
    ]
    
    private let VERTICAL_BRTAB2 = [
        TileConstants.VBRIDGE, TileConstants.RIVER,
        TileConstants.VBRIDGE, TileConstants.VBRIDGE,
        TileConstants.VBRIDGE, TileConstants.VBRIDGE,
        TileConstants.RIVER
    ]
    
    private func processBridge() -> Bool {
        if tile == TileConstants.BRWV {
            if arc4random_uniform(4) == 0 && getBoatDistance() > 340/16 {
                applyBridgeChange(VERTICAL_DX, dy: VERTICAL_DY, from: VERTICAL_BRTAB, to: VERTICAL_BRTAB2)
            }
            return true
        } else if tile == TileConstants.BRWH {
            if arc4random_uniform(4) == 0 && getBoatDistance() > 340/16 {
                applyBridgeChange(HORIZONTAL_DX, dy: HORIZONTAL_DY, from: HORIZONAL_BRTAB, to: HORIZONAL_BRTAB2)
            }
            return true
        }
        
        if getBoatDistance() < 300/16 && arc4random_uniform(8) == 0 {
            if tile & 1 != 0 {
                if xPos < city.map.width - 1 && city.getTile(x: xPos + 1, y: yPos) == TileConstants.CHANNEL {
                    applyBridgeChange(VERTICAL_DX, dy: VERTICAL_DY, from: VERTICAL_BRTAB2, to: VERTICAL_BRTAB)
                    return true
                }
                
                return false
            } else if xPos > 0 {
                if city.getTile(x: xPos, y: yPos - 1) == TileConstants.CHANNEL {
                    applyBridgeChange(HORIZONTAL_DX, dy: HORIZONTAL_DY, from: HORIZONAL_BRTAB2, to: HORIZONAL_BRTAB)
                    return true
                }
                
                return false
            }
        }
        
        return false
    }
    
    private func getBoatDistance() -> Int {
        return Int.max
    }
    
    private func applyBridgeChange(dx: [Int], dy: [Int], from: [UInt16], to: [UInt16]) {
        for z in 0...6 {
            let x = xPos + dx[z]
            let y = yPos + dy[z]
            if city.withinBounds(x: x, y: y) {
                let tile = city.getTile(x: x, y: y)
                if tile == from[z] || tile == TileConstants.CHANNEL {
                    city.setTile(x: x, y: y, tile: to[z])
                }
            }
        }
    }

}
