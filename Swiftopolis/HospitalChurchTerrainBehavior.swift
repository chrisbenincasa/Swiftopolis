//
//  HospitalChurchTerrainBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/7/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class HospitalChurchTerrainBehavior: BuildingZoneBehavior {

    override func apply() {
        assert(tile == TileConstants.HOSPITAL || tile == TileConstants.CHURCH, "Tried to doHospitalChurch on wrong tile")
        
        if city.cityTime % 16 == 0 {
            repairZone(tile)
        }
        
        let needForTile = tile == TileConstants.HOSPITAL ? city.demand.needHospital : city.demand.needChurch
        if needForTile == -1 && arc4random_uniform(21) == 0 {
            zonePlop(Tiles.load(Int(TileConstants.RESCLR)))
        }
        
        if tile == TileConstants.HOSPITAL {
            // increase city hospital count
        } else if tile == TileConstants.CHURCH {
            // inc city church count
        }
    }
}
