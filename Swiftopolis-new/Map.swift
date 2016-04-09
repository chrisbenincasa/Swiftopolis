//
//  Map.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/29/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

struct MapConstants {
    static let MAX_TRAFFIC: Int = 240
}

class Map {

    private(set) var width: Int
    private(set) var height: Int
    private var map: [[UInt16]] = []
    private var powerMap: [[Bool]] = []
    
    // [0, 250]
    private var landValueMem: [[UInt16]] = []
    private var pollutionMem: [[UInt16]] = []
    private var crimeMem: [[UInt16]] = []
    private var populationDensity: [[UInt16]] = []
    private var trafficDensity: [[UInt16]] = []
    
    private var terrainMem: [[Int]] = [] // Natural land features for each 4x4 section
    private(set) var fireMap: [[Int]] = []
    private(set) var fireReachMap: [[Int]] = []
    private(set) var policeMap: [[Int]] = []
    private(set) var policeReachMap: [[Int]] = []
    private(set) var rateOfGrowthMem: [[Int16]] = [] // [-200, 200]
    private(set) var commercialRate: [[UInt8]] = []
    
    private(set) var centerOfMassX: Int = 0
    private(set) var centerOfMassY: Int = 0
    
    var crimeMaxLocation = CityLocation(x: 0, y: 0)
    var pollutionMaxLocation = CityLocation(x: 0, y: 0)
    
    init(width: Int = 120, height: Int = 100) {
        self.width = width
        self.height = height
        
        Utils.initializeMatrix(&self.powerMap, width: self.height, height: self.width, value: false)
        
        let halfHeight = (self.height + 1) / 2,
            halfWidth = (self.width + 1) / 2
        
        centerOfMassX = halfWidth
        centerOfMassY = halfHeight
        
        Utils.initializeMatrix(&self.landValueMem, width: halfHeight, height: halfWidth, value: 0)
        Utils.initializeMatrix(&self.pollutionMem, width: halfHeight, height: halfWidth, value: 0)
        Utils.initializeMatrix(&self.crimeMem, width: halfHeight, height: halfWidth, value: 0)
        Utils.initializeMatrix(&self.populationDensity, width: halfHeight, height: halfWidth, value: 0)
        Utils.initializeMatrix(&self.trafficDensity, width: halfHeight, height: halfWidth, value: 0)
        
        let quarterHeight = (self.height + 3) / 4,
            quarterWidth = (self.width + 3) / 4
        
        Utils.initializeMatrix(&self.terrainMem, width: quarterHeight, height: quarterWidth, value: 0)
        
        let smallHeight = (self.width + 7) / 8,
            smallWidth = (self.width + 7) / 8
        
        Utils.initializeMatrix(&self.rateOfGrowthMem, width: smallHeight, height: smallWidth, value: 0)
        Utils.initializeMatrix(&self.commercialRate, width: smallHeight, height: smallWidth, value: 0)
        Utils.initializeMatrix(&self.fireMap, width: smallHeight, height: smallWidth, value: 0)
        Utils.initializeMatrix(&self.policeMap, width: smallHeight, height: smallWidth, value: 0)
        Utils.initializeMatrix(&self.policeReachMap, width: smallHeight, height: smallWidth, value: 0)
    }
    
    func withinBounds(x xpos: Int, y ypos: Int) -> Bool {
        return xpos >= 0 && xpos < width && ypos >= 0 && ypos < height
    }
    
    func getTile(x xpos: Int, y ypos: Int) -> UInt16? {
        if let tile = getRawTile(x: xpos, y: ypos) {
            return tile & TileConstants.LOMASK
        } else {
            return nil
        }
    }
    
    func setTile(x xpos: Int, y ypos: Int, tile newTile: UInt16) -> Bool {
        assert(newTile & TileConstants.LOMASK == newTile, "Don't set the upper bit")
        
        if map[ypos][xpos] != newTile {
            map[ypos][xpos] = newTile
            return true
        }
        
        return false
    }
    
    func getRawTile(x xpos: Int, y ypos: Int) -> UInt16? {
        if withinBounds(x: xpos, y: ypos) {
            return map[ypos][xpos]
        } else {
            return nil
        }
    }
    
    func setMap(map: [[UInt16]]) {
        self.map = map
    }
    
    func distanceToCityCenter(x x: Int, y: Int) -> Int {
        let xDis = abs(x - (centerOfMassX / 2)),
            yDis = abs(y - (centerOfMassY / 2)),
            z = xDis + yDis
        
        return z > 32 ? 32 : z
    }
    
    func setMapCenterOfMass(x xpos: Int, y ypos: Int) {
        self.centerOfMassX = xpos
        self.centerOfMassY = ypos
    }
    
    // MARK: Power functions
    
    // Checks if the power bit is set
    func isTilePowered(x xpos: Int, y ypos: Int) -> Bool {
        return (map[ypos][xpos] & TileConstants.POWERBIT) == TileConstants.POWERBIT
    }
    
    func locationHasAccessToPower(x xpos: Int, y ypos: Int) -> Bool {
        return powerMap[ypos][xpos]
    }
    
    func setTilePower(x xpos: Int, y ypos: Int, power: Bool) -> Bool {
        if isTilePowered(x: xpos, y: ypos) == power {
            return false
        }
        
        map[ypos][xpos] = map[ypos][xpos] & (~TileConstants.POWERBIT) | (power ? TileConstants.POWERBIT : 0)
        
        return true
    }
    
    // Used in powerScan
    func clearPowerMap() {
        for i in 0 ..< powerMap.count {
            powerMap[i] = [Bool](count: powerMap[i].count, repeatedValue: false)
        }
    }
    
    func setPowerMap(x xpos: Int, y ypos: Int, value: Bool) {
        powerMap[ypos][xpos] = value
    }
    
    // MARK: Traffic functions
    
    func trafficDensityAtLocation(x xpos: Int, y ypos: Int) -> UInt16 {
        if withinBounds(x: xpos, y: ypos) {
            return trafficDensity[ypos / 2][xpos / 2]
        } else {
            return 0
        }
    }
    
    func increaseTrafficDensity(x xpos: Int, y ypos: Int, amount: Int = 1) -> UInt16 {
        let currentDensity = trafficDensity[ypos / 2][xpos / 2]
        var newDensity = Int(currentDensity) + amount
        
        if newDensity > MapConstants.MAX_TRAFFIC {
            newDensity = MapConstants.MAX_TRAFFIC
        }
        
        trafficDensity[ypos / 2][xpos / 2] = UInt16(newDensity)
        
        return trafficDensity[ypos / 2][xpos / 2]
    }
    
    func foreachTrafficDensity(f: (Int, Int, inout UInt16) -> Void) {
        for y in 0 ..< trafficDensity.count {
            for x in 0 ..< trafficDensity[y].count {
                f(x, y, &trafficDensity[y][x])
            }
        }
    }
    
    // MARK: Land Value
    
    func getLandValueAtLocation(x xpos: Int, y ypos: Int) -> UInt16 {
        if withinBounds(x: xpos, y: ypos) {
            return landValueMem[ypos / 2][xpos / 2]
        } else {
            return 0
        }
    }
    
    func setLandValueAtLocation(x xpos: Int, y ypos: Int, amount: UInt16, factor: Int = 2) {
        if withinBounds(x: xpos, y: ypos) {
            landValueMem[ypos / factor][xpos / factor] = amount
        }
    }
    
    func increaseLandValueAtLocation(x xpos: Int, y ypos: Int, amount: Int = 1, factor: Int = 2) {
        if withinBounds(x: xpos, y: ypos) {
            landValueMem[ypos / factor][xpos / factor] += (amount < 0 ? 0 : UInt16(amount))
        }
    }
    
    func foreachLandValue(f: (UInt16, (Int, Int)) -> Void) {
        for y in 0...landValueMem.count - 1 {
            for x in 0...landValueMem[y].count - 1 {
                f(landValueMem[y][x], (x, y))
            }
        }
    }
    
    // MARK: Pollution
    
    func getPollutionLevelAtLocation(x xpos: Int, y ypos: Int, factor: Int = 2) -> UInt16 {
        if withinBounds(x: xpos, y: ypos) {
            return pollutionMem[ypos / factor][xpos / factor]
        } else {
            return 0
        }
    }
    
    func increasePollutionLevelAtLocation(x xpos: Int, y ypos: Int, amount: Int = 1) {
        
    }
    
    func setPollutionLevelAtLocation(x x: Int, y: Int, value: UInt16, factor: Int = 2) {
        if withinBounds(x: x, y: y) {
            pollutionMem[y / factor][x / factor] = value
        }
    }
    
    // MARK: Rate Of Growth
    
    func increaseRateOfGrowth(x xpos: Int, y ypos: Int, amount: Int = 1, byFactor: Int = 4) {
        if withinBounds(x: xpos, y: ypos) {
            rateOfGrowthMem[ypos / 8][xpos / 8] += (byFactor * amount)
        }
    }
    
    func setRateOfGrowthAtLocation(x xpos: Int, y ypos: Int, value: Int, factor: Int = 8) {
        if withinBounds(x: xpos, y: ypos) {
            rateOfGrowthMem[ypos / factor][xpos / factor] = Int16(value)
        }
    }
    
    // MARK: Population Density
    
    func getPopulationDensityAtLocation(x xpos: Int, y ypos: Int, factor: Int = 2) -> UInt16 {
        if withinBounds(x: xpos, y: ypos) {
            return populationDensity[ypos / factor][xpos / factor]
        } else {
            return 0
        }
    }
    
    func setPopulationDensityAtLocation(x xpos: Int, y ypos: Int, value: UInt16, factor: Int = 2) {
        self.populationDensity[ypos / factor][xpos / factor] = value
    }
    
    func getCommercialRateAtLocation(x xpos: Int, y ypos: Int) -> UInt8 {
        if withinBounds(x: xpos, y: ypos) {
            return commercialRate[ypos / 8][xpos / 8]
        } else {
            return 0
        }
    }
    
    // MARK: Fire Map
    func adjustFireCoverageAtLocation(x xpos: Int, y ypos: Int, amount: Int) {
        if withinBounds(x: xpos, y: ypos) {
            fireMap[ypos / 8][xpos / 8] += amount
        }
    }
    
    func setFireEffectAtLocation(x x: Int, y: Int, value: Int) {
        self.fireReachMap[y][x] = value
    }
    
    func setFireMap(map: [[Int]]) {
        self.fireMap = map
    }
    
    func setFireReachMap(map: [[Int]]) {
        self.fireReachMap = map
    }
    
    func clearFireMap() {
        let y = fireMap.count
        let x = fireMap.count > 0 ? fireMap[0].count : 0
        Utils.initializeMatrix(&fireMap, width: y, height: x, value: 0)
    }
    
    // MARK: Police Map
    
    func adjustPoliceMapAtLocation(x xpos: Int, y ypos: Int, amount: Int) {
        if withinBounds(x: xpos, y: ypos) {
            policeMap[ypos / 8][xpos / 8] += amount
        }
    }
    
    func getCrimeAtLocation(x x: Int, y: Int, factor: Int = 2) -> UInt16 {
        if withinBounds(x: x, y: y) {
            return crimeMem[y / factor][x / factor]
        } else {
            return 0
        }
    }
    
    func setCrimeAtLocation(x x: Int, y: Int, value: UInt16, factor: Int = 2) {
        if withinBounds(x: x, y: y) {
            crimeMem[y / factor][x / factor] = value
        }
    }
    
    func setPoliceReachMap(arr: [[Int]]) {
        self.policeReachMap = arr
    }
    
    func getPoliceCoverageAtLocation(x x: Int, y: Int, factor: Int = 2) -> Int {
        if withinBounds(x: x, y: y) {
            return self.policeMap[y / factor][x / factor]
        } else {
            return 0
        }
    }
    
    func setPoliceMap(arr: [[Int]]) {
        self.policeMap = arr
    }
    
    func clearPoliceMap() {
        let y = policeMap.count
        let x = policeMap.count > 0 ? policeMap[0].count : 0
        Utils.initializeMatrix(&policeMap, width: y, height: x, value: 0)
    }
    
    // MARK: Terrain Map
    
    func getTerrainFeaturesAtLocation(x x: Int, y: Int, factor: Int = 2) -> Int {
        if withinBounds(x: x, y: y) {
            return terrainMem[y / factor][x / factor]
        } else {
            return 0
        }
    }
    
    func setTerrainFeatures(arr: [[Int]]) {
        self.terrainMem = arr
    }
    
    // MARK: Commerical Rate Map
    
    func foreachCommercialRate(f: (Int, Int, inout UInt8) -> Void) {
        for y in 0 ..< commercialRate.count {
            for x in 0 ..< commercialRate[y].count {
                f(x, y, &commercialRate[y][x])
            }
        }
    }
}

enum MapState : Int {
    case All, Residential, Commercial, Industrial, LandValue, Transport, GrowthRate, Crime, Pollution, Traffic, Power, Fire, Police, Population
}
