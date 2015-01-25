//
//  StadiumTileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/25/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

class StadiumTileBehavior: BuildingZoneBehavior {
    var isEmpty: Bool = false
    
    init(city: City, isEmpty: Bool) {
        super.init(city: city)
        self.isEmpty = isEmpty
    }
    
    override func apply() {
        if isEmpty {
            doEmptyStadium()
        } else {
            doFullStadium()
        }
    }
    
    private func doEmptyStadium() {
        let powerOn = checkZonePower()
        city.census.stadiumCount++
        
        if city.cityTime % 16 == 0 {
            repairZone(TileConstants.STADIUM)
        }
        
        if powerOn {
            if (city.cityTime + xPos + yPos) % 32 == 0 {
                drawStadium(TileConstants.FULLSTADIUM)
                city.setTile(x: xPos + 1, y: yPos, tile: TileConstants.FOOTBALLGAME1)
                city.setTile(x: xPos + 1, y: yPos + 1, tile: TileConstants.FOOTBALLGAME2)
            }
        }
    }
    
    private func doFullStadium() {
        city.census.stadiumCount++
        
        if (city.cityTime + xPos + yPos) % 8 == 0 {
            drawStadium(TileConstants.STADIUM)
        }
    }
    
    private func drawStadium(type: UInt16) {
        var zoneBase: UInt16 = type - 1 - 4
        
        for y in 0..<4 {
            for x in 0..<4 {
                city.setTile(x: xPos - 1 + x, y: yPos - 1 + y, tile: zoneBase)
                zoneBase++
            }
        }
        
        city.setTilePower(x: xPos, y: yPos, power: true)
    }
}