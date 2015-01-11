//
//  CoalPowerTileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/8/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class CoalPowerTileBehavior: BuildingZoneBehavior {

    override func apply() {
        city.census.coalCount++
        if city.cityTime % 8 == 0 {
            repairZone(TileConstants.POWERPLANT)
        }
        
        city.addPowerPlantAtLocation(x: xPos, y: yPos)
    }
}
