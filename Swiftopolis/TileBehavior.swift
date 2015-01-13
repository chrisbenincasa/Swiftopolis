//
//  TileBehavior.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

protocol TileBehaviorProtocol {
    typealias ResultType

    var city: City { get }
    var xPos: Int { get }
    var yPos: Int { get }
    var tile: UInt16 { get }
    
    init(city: City)
    
    func processTile(x: Int, y: Int)
    
    func apply() -> ResultType
}

class TileBehavior: TileBehaviorProtocol {
    var xPos: Int = -1
    var yPos: Int = -1
    var tile: UInt16 = UInt16.max
    var city: City
    
    required init(city: City) {
        self.city = city
    }
    
    func processTile(x: Int, y: Int) {
        self.xPos = x
        self.yPos = y
        self.tile = self.city.getTile(x: x, y: y)
    }
    
    func apply() {
        fatalError("TerrainBehavior must be subclassed")
    }
}

class BuildingZoneBehavior: TileBehavior {
    
    lazy var traffic: TrafficGenerator = TrafficGenerator(city: self.city)
    
    internal func checkZonePower() -> Bool {
        return true
    }
    
    internal func setZonePower() -> Bool {
        let oldPower = city.isTilePowered(x: xPos, y: yPos)
        let newPower = tile == TileConstants.NUCLEAR || tile == TileConstants.POWERPLANT || city.hasPower(x: xPos, y: yPos)
        
        if newPower && !oldPower {
            city.setTilePower(x: xPos, y: yPos, power: true)
            let (width, height) = TileConstants.getZoneSize(tile)!
            city.turnOnZonePower(x: xPos, y: yPos, width: width, height: height)
        } else if !newPower && oldPower {
            city.setTilePower(x: xPos, y: yPos, power: false)
            let (width, height) = TileConstants.getZoneSize(tile)!
            city.shutdownZonePower(x: xPos, y: yPos, width: width, height: height)
        }
        
        return newPower
    }
    
    internal func makeTraffic(zone: Zone) -> Int {
        self.traffic.setMapLocation(xPos, y: yPos)
        self.traffic.setZone(zone)
        return self.traffic.makeTraffic()
    }
    
    internal func getCRValue() -> Int {
        let landValue = city.getLandValue(x: xPos, y: yPos) - city.getPollution(x: xPos, y: yPos)
        switch landValue {
        case 0...29: return 0
        case 30...79: return 1
        case 80...150: return 2
        default: return 3
        }
    }
    
    internal func zonePlop(base: Tile) -> Bool {
        assert(base.isZone, "TRYING TO PLACE A NON-ZONE")
        
        if let buildingInfo = base.buildingInfo {
            let xOrg = xPos - 1, yOrg = yPos - 1
            for y in yOrg...(yOrg + buildingInfo.height - 1) {
                for x in xOrg...(xOrg + buildingInfo.width - 1) {
                    if !city.withinBounds(x: x, y: y) {
                        return false
                    }
                    if TileConstants.isIndustructible(city.getTile(x: x, y: y)) {
                        return false
                    }
                }
            }
            
            assert(buildingInfo.members.count == buildingInfo.width * buildingInfo.height, "Unequal members")
            var i = 0
            for y in yOrg...(yOrg + buildingInfo.height - 1) {
                for x in xOrg...(xOrg + buildingInfo.width - 1) {
                    city.setTile(x: x, y: y, tile: buildingInfo.members[i].tileNumber)
                    i++
                }
            }
            
            self.tile = city.getTile(x: xPos, y: yPos)
            
            setZonePower()
            
            return true
        } else {
            return false
        }
    }
    
    internal func makeHospitalOrChurch() {
        if city.demand.needHospital > 0 {
            zonePlop(Tiles.load(Int(TileConstants.HOSPITAL)))
            city.demand.setHospitalDemand(0)
        }
        
        if city.demand.needChurch > 0 {
            zonePlop(Tiles.load(Int(TileConstants.CHURCH)))
            city.demand.setChurchDemand(0)
        }
    }
    
    /**
    * Regenerate the tiles that make up a building zone,
    * repairing from fire, etc.
    * Only tiles that are not rubble, radioactive, flooded, or
    * on fire will be regenerated.
    *
    * @param base The "zone" tile spec for this zone.
    */
    internal func repairZone(base: UInt16) {
        assert(TileConstants.isZoneCenter(base), "not isZoneCenter in repairZone")
        
        let powerOn = city.isTilePowered(x: xPos, y: yPos)
        let buildingInfo = Tiles.getTile(Int(base))!.buildingInfo!
        
        var xOrg = xPos - 1, yOrg = yPos - 1
        assert(buildingInfo.members.count == buildingInfo.width * buildingInfo.height, "height * width != memebers")
        
        for var y = 0, i = 0; y < buildingInfo.height; y++ {
            for var x = 0; x < buildingInfo.width; x++, i++ {
                let xx = xOrg + x, yy = yOrg + y
                var tile = buildingInfo.members[i]
                if (powerOn && tile.onPower != nil) {
                    tile = Tiles.load(tile.onPower!)
                }
                
                if city.withinBounds(x: xx, y: yy) {
                    let t = city.getTile(x: xx, y: yy)
                    if TileConstants.isZoneCenter(t) || TileConstants.isAnimated(t) || TileConstants.isRubble(t) {
                        continue
                    }
                    
                    if !TileConstants.isIndustructible(t) {
                        city.setTile(x: xx, y: yy, tile: tile.tileNumber)
                    }
                }
            }
        }
    }
}
