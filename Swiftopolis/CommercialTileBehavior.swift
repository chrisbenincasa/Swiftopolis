//
//  CommercialTileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/8/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class CommercialTileBehavior: BuildingZoneBehavior {

    override func apply() {
        let powerOn = checkZonePower()
        city.adjustCommercialZones()
        
        let population = TileConstants.commercialZonePopulation(tile)
        city.adjustCommercialPopulation(amount: population)
        
        let trafficGood = population > Int(arc4random_uniform(6)) ? makeTraffic(.Commercial) : 1
        if trafficGood == -1 {
            doCommercialOut(population, value: getCRValue())
            return
        }

        if arc4random_uniform(8) == 0 {
            let locationValue = evalCommercial(trafficGood)
            var zScore = city.demand.commercialDemand + locationValue
            
            if !powerOn {
                zScore = -500
            }
            
            if trafficGood != 0 && zScore > -350 && zScore - 26380 > Int(arc4random_uniform(0x10000)) - 0x8000 {
                doCommercialIn(population, value: getCRValue())
            }
            
            if zScore < 350 && zScore + 26380 < Int(arc4random_uniform(0x10000)) - 0x8000 {
                doCommercialOut(population, value: getCRValue())
            }
        }
    }
    
    private func doCommercialOut(population: Int, value: Int) {
        if population > 1 {
            commercialPlop(population - 2, value: value)
            city.adjustRateOfGrowth(x: xPos, y: yPos, amount: -8)
        } else if population == 1 {
            zonePlop(Tiles.load(Int(TileConstants.COMCLR)))
            city.adjustRateOfGrowth(x: xPos, y: yPos, amount: -8)
        }
    }
    
    private func doCommercialIn(population: Int, value: Int) {
        let z = city.getLandValue(x: xPos, y: yPos) / 32
        if population > Int(z) {
            return
        }
        
        if population < 5 {
            commercialPlop(population, value: value)
            city.adjustRateOfGrowth(x: xPos, y: yPos, amount: 8)
        }
    }
    
    private func evalCommercial(trafficGood: Int) -> Int {
        if trafficGood < 0 {
            return -3000
        }
        
        return Int(city.map.getCommercialRateAtLocation(x: xPos, y: yPos))
    }
    
    private func commercialPlop(density: Int, value: Int) {
        zonePlop(Tiles.load((value * 5 + density) * 9 + Int(TileConstants.CZB)))
    }
}
