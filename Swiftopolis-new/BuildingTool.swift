//
//  BuildingTool.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/22/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

class BuildingTool: ToolStroke {
 
    override func dragTo(x: Int, _ y: Int) {
        xSrc = x
        xDest = x
        ySrc = y
        yDest = y
    }
    
    override func applyWithEffect(effect: AbstractToolEffect) -> Bool {
        var tile: UInt16!
        switch tool {
        case .FireStation:
            tile = TileConstants.FIRESTATION
            break
        case .PoliceStation:
            tile = TileConstants.POLICESTATION
            break
        case .Coal:
            tile = TileConstants.POWERPLANT
            break
        case .Stadium:
            tile = TileConstants.STADIUM
            break
        case .Seaport:
            tile = TileConstants.PORT
            break
        case .Nuclear:
            tile = TileConstants.NUCLEAR
            break
        case .Airport:
            tile = TileConstants.AIRPORT
            break
        default: fatalError("Unexpected tool: \(tool)")
        }
        
        return applyZone(effect, Tiles.load(Int(tile)))
    }
}