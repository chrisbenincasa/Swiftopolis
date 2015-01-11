//
//  FireStationTileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/8/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class FireStationTileBehavior: BuildingZoneBehavior {

    override func apply() {
        let powerOn = checkZonePower()
        city.census.fireStationCount++
        
        if city.cityTime % 8 == 0 {
            repairZone(TileConstants.FIRESTATION)
        }
        
        var z = powerOn ? city.budget.fireEffect : city.budget.fireEffect / 2
        traffic.setMapLocation(xPos, y: yPos)
        if !traffic.hasPerimeterRoad() {
            z /= 2
        }
        
        city.map.adjustFireCoverageAtLocation(x: xPos, y: yPos, amount: z)
    }
}
