//
//  PoliceStationTileEffect.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/8/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class PoliceStationTileEffect: BuildingZoneBehavior {

    override func apply() {
        let powerOn = checkZonePower()
        city.census.policeCount++
        
        if city.cityTime % 8 == 0 {
            repairZone(TileConstants.POLICESTATION)
        }
        
        var z = powerOn ? city.budget.policeEffect : city.budget.policeEffect / 2
        traffic.setMapLocation(xPos, y: yPos)
        if !traffic.hasPerimeterRoad() {
            z /= 2
        }
        
        city.map.adjustPoliceMapAtLocation(x: xPos, y: yPos, amount: z)
    }
}
