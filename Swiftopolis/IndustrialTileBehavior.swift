//
//  IndustrialTileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/8/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class IndustrialTileBehavior: BuildingZoneBehavior {
    
    override func apply() {
        let powerOn = checkZonePower()
        city.adjustIndustrialZones()
        
        let population = TileConstants.industrialZonePopulation(tile)
        city.adjustIndustrialPopulation(amount: population)
        
        let trafficGood = population > Int(arc4random_uniform(6)) ? makeTraffic(.Industrial) : 1
        if trafficGood == -1 {
            doIndustrialOut(population, value: Int(arc4random_uniform(2)))
            return
        }

        if arc4random_uniform(8) == 0 {
            let locationValue = evalIndustrial(trafficGood)
            var zScore = city.demand.industrialDemand + locationValue
            
            if !powerOn {
                zScore = -500
            }
            
            if zScore > -350 && zScore - 26380 > Int(arc4random_uniform(0x10000)) - 0x8000 {
                doIndustrialIn(population, value: Int(arc4random_uniform(2)))
                return
            }
            
            if zScore < 350 && zScore + 26380 < Int(arc4random_uniform(0x10000)) - 0x8000 {
                doIndustrialOut(population, value: Int(arc4random_uniform(2)))
            }
        }
    }
    
    private func doIndustrialOut(population: Int, value: Int) {
        if population > 1 {
            industrialPlop(population - 2, value: value)
            city.adjustRateOfGrowth(x: xPos, y: yPos, amount: -8)
        } else if population == 1 {
            zonePlop(Tiles.load(Int(TileConstants.INDCLR)))
            city.adjustRateOfGrowth(x: xPos, y: yPos, amount: -8)
        }
    }
    
    private func doIndustrialIn(population: Int, value: Int) {
        if population < 4 {
            industrialPlop(population, value: value)
            city.adjustRateOfGrowth(x: xPos, y: yPos, amount: 8)
        }
    }
    
    private func evalIndustrial(trafficGood: Int) -> Int {
        return trafficGood < 0 ? -1000 : 0
    }
    
    private func industrialPlop(density: Int, value: Int) {
        zonePlop(Tiles.load((value * 4 + density) * 9 + Int(TileConstants.IZB)))
    }
}
