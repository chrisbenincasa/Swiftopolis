//
//  ResidentialTileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/6/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class ResidentialTileBehavior: BuildingZoneBehavior {

    
    override func apply() {
        let isZonePowered = checkZonePower()
        city.adjustResidentialZones()
        
        let tpop = tile == TileConstants.RESCLR ? city.doFreePop(x: xPos, y: yPos) : TileConstants.residentialZonePopulation(tile)
        city.adjustResidentialPopulation(amount: tpop)
        
        let trafficGood = tpop > Int(arc4random_uniform(36)) ? makeTraffic(.Residential) : 1
        
        if trafficGood == -1 {
            doResidentialOut(tpop, value: getCRValue())
            return
        }

        if tile == TileConstants.RESCLR || Int(arc4random_uniform(8)) == 0 {
            var zoneScore = city.demand.residentialDemand + evaluateResidentialZone(trafficGood)
            
            if !isZonePowered {
                zoneScore -= 500
            }

            if zoneScore > -350 && zoneScore - 26380 > Int(arc4random_uniform(0x10000)) - 0x8000 {
                if tpop == 0 && arc4random_uniform(4) == 0 {
                    // makeHospital()
                    return
                }

                doResidentialIn(tpop, value: getCRValue())
                return
            }

            if zoneScore < 350 && zoneScore + 26380 < Int(arc4random_uniform(0x10000)) - 0x8000 {
                doResidentialOut(tpop, value: getCRValue())
            }
        }
    }
    
    private let Brdr: [UInt16] = [ 0, 3, 6, 1, 4, 7, 2, 5, 8 ];
    
    private func doResidentialIn(population: Int, value: Int) {
        assert(value >= 0 && value < 4, "Wrong value in doResidentialOut")
        
        let z = city.getPollution(x: xPos, y: yPos)
        if z > 128 {
            return
        }
        
        if tile == TileConstants.RESCLR {
            if population < 8 {
                buildHouse(value)
                city.adjustRateOfGrowth(x: xPos, y: yPos, amount: 1)
                return
            }
            
            if city.getPopulationDensity(x: xPos, y: yPos) > 64 {
                residentialPlop(0, value: value)
                city.adjustRateOfGrowth(x: xPos, y: yPos, amount: 8)
                return
            }
            
            return
        }
        
        if population < 40 {
            residentialPlop(population / 8 - 1, value: value)
            city.adjustRateOfGrowth(x: xPos, y: yPos, amount: 8)
        }
    }
    
    private func doResidentialOut(population: Int, value: Int) {
        assert(value >= 0 && value < 4, "Wrong value in doResidentialOut")
        
        if population == 0 {
            return
        } else if population > 16 {
            residentialPlop((population - 24) / 8, value: value)
            city.adjustRateOfGrowth(x: xPos, y: yPos, amount: -8)
        } else if population == 16 {
            let powered = city.isTilePowered(x: xPos, y: yPos)
            city.setTile(x: xPos, y: yPos, tile: TileConstants.RESCLR)
            city.setTilePower(x: xPos, y: yPos, power: powered)
            for var x = xPos - 1; x <= xPos + 1; x++ {
                for var y = yPos - 1; y <= yPos + 1; y++ {
                    if city.withinBounds(x: x, y: y) && !(x == xPos && y == yPos) {
                        city.setTile(x: x, y: y, tile: TileConstants.HOUSE + UInt16(value * 3 + arc4random_uniform(3)))
                    }
                }
            }
            
            city.adjustRateOfGrowth(x: xPos, y: yPos, amount: -8)
        } else if population < 16 {
            city.adjustRateOfGrowth(x: xPos, y: yPos, amount: -1)
            var z = 0
            for var x = xPos - 1; x <= xPos + 1; x++ {
                for var y = yPos - 1; y <= yPos + 1; y++ {
                    if city.withinBounds(x: x, y: y){
                        let loc = city.getTile(x: x, y: y)
                        if loc >= TileConstants.LHTHR && loc <= TileConstants.HHTHR {
                            city.setTile(x: x, y: y, tile: Brdr[z] + TileConstants.RESCLR - 4)
                        }
                    }
                    z++
                }
            }
        }
    }
    
    private func residentialPlop(density: Int, value: Int) {
        let base = (value * 4 + density) * 9 + TileConstants.RZB
        zonePlop(Tiles.load(Int(base)))
    }
    
    private func buildHouse(value: Int) {
        assert(value >= 0 && value < 4, "Wrong value in buildHouse")
        
        let ZeX = [ 0, -1, 0, 1, -1, 1, -1, 0, 1 ];
        let ZeY = [ 0, -1, -1, -1, 0, 0, 1, 1, 1 ];
        
        var bestLocation = 0, hScore = 0
        
        for z in 1...8 {
            let xx = xPos + ZeX[z], yy = yPos + ZeY[z]
            
            if city.withinBounds(x: xx, y: yy) {
                let score = evaluatePotentialLot(x: xx, y: yy)
                if score != 0 {
                    if score > hScore {
                        hScore = score
                        bestLocation = z
                    }
                    
                    if score == hScore && arc4random_uniform(8) == 0 {
                        bestLocation = z
                    }
                }
            }
        }
    }
    
    /**
     * Consider the value of building a single-lot house at certain
     * coordinates.
     * @return integer; positive number indicates good place for
     * house to go; zero or a negative number indicates a bad place.
     */
    private func evaluatePotentialLot(x xpos: Int, y ypos: Int) -> Int {
        let tile = city.getTile(x: xpos, y: ypos)
        if tile != TileConstants.DIRT && !TileConstants.isResidentialClear(tile) {
            return -1
        }
        
        var score = 1
        let DX = [ 0, 1, 0, -1 ], DY = [ -1, 0, 1, 0 ]
        for z in 0...3 {
            let xx = xpos + DX[z], yy = ypos + DY[z]
            if city.withinBounds(x: xx, y: yy) {
                let tempTile = city.getTile(x: xx, y: yy)
                if TileConstants.isRoad(tempTile) || TileConstants.isRail(tempTile) {
                    score++
                }
            }
        }
        
        return score
    }
    
    /**
     * Evaluates the zone value of the current residential zone location.
     * @return an integer between -3000 and 3000. The higher the
     * number, the more likely the zone is to GROW; the lower the
     * number, the more likely the zone is to SHRINK.
     */
    private func evaluateResidentialZone(traffic: Int) -> Int {
        if traffic < 0 {
            return -3000
        }
        
        var landValue = city.getLandValue(x: xPos, y: yPos) - city.getPollution(x: xPos, y: yPos)
        if landValue < 0 {
            landValue = 0
        } else {
            landValue *= 32
        }
        
        if landValue > 6000 {
            landValue = 6000
        }
        
        return Int(landValue) - 3000
    }
}
