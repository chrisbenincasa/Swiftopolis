//
//  SeaportTileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/25/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

class SeaportTileBehavior : BuildingZoneBehavior {
    override func apply() {
        city.census.seaportCount++
        
        if city.cityTime % 16 == 0 {
            repairZone(TileConstants.PORT)
        }
        
        if checkZonePower() {
            city.spawnShip(xPos, yPos)
        }
    }
}