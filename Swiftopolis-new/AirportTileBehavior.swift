//
//  AirportTileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/25/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

class AirportTileBehavior: BuildingZoneBehavior {
    
    override func apply() {
        let powerOn = checkZonePower()
        city.census.airportCount++
        
        if city.cityTime % 8 == 0 {
            repairZone(TileConstants.AIRPORT)
        }
        
        if powerOn {
            if arc4random_uniform(6) == 0 {
                city.spawnAirplane(xPos, yPos)
            }
            
            if arc4random_uniform(13) == 0 {
                city.spawnHelicopter(xPos, yPos)
            }
        }
    }
}