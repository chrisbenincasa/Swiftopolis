//
//  NuclearTileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/8/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class NuclearTileBehavior: BuildingZoneBehavior {

    override func apply() {
        if !city.disasterFree && arc4random_uniform(city.nuclearMeltdownProb()) == 0 {
            // city.doMeltdown()
            return
        }
        
        city.census.nuclearCount++
        
        if city.cityTime % 8 == 0 {
            repairZone(TileConstants.NUCLEAR)
        }
        
        city.addPowerPlantAtLocation(x: xPos, y: yPos)
    }
}
