//
//  TrafficGenerator.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/6/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class TrafficGenerator {

    private var city: City
    private var mapX: Int = 0
    private var mapY: Int = 0
    private var sourceZone: Zone?
    private var lastDir: Int = 0
    private var positionsStack: [(Int, Int)] = []
    
    let PERIM_X = [ -1, 0, 1,  2, 2, 2,  1, 0,-1, -2,-2,-2 ]
    let PERIM_Y = [ -2,-2,-2, -1, 0, 1,  2, 2, 2,  1, 0,-1 ]
    let MAX_TRAFFIC_DISTANCE = 30
    
    init(city: City) {
        self.city = city
    }
    
    func setMapLocation(x: Int, y: Int) {
        self.mapX = x
        self.mapY = y
    }
    
    func setZone(zone: Zone) {
        self.sourceZone = zone
    }
    
    func makeTraffic() -> Int {
        if hasPerimeterRoad() {
            if tryDrive() {
                setTrafficMem()
                return 1
            } else {
                return 0
            }
        } else {
            return -1
        }
    }
    
    func setTrafficMem() {
        for var i = positionsStack.count - 1; i >= 0; i-- {
            let (x, y) = positionsStack[i]
            mapX = x
            mapY = y
            assert(city.withinBounds(x: x, y: y), "Traffic gen flubbed")
            
            let tile = city.getTile(x: x, y: y)
            if tile >= TileConstants.ROADBASE && tile < TileConstants.POWERBASE {
                city.addTraffic(x: mapX, y: mapY, amount: 50)
            }
        }
        
        positionsStack.removeAll(keepCapacity: true)
    }
    
    func hasPerimeterRoad() -> Bool {
        for z in 0...11 {
            let tx = mapX + PERIM_X[z]
            let ty = mapY + PERIM_Y[z]
            if isRoadLike(tx, y: ty) {
                mapX = tx
                mapY = ty
                return true
            }
        }
        
        return false
    }
    
    private func isRoadLike(x: Int, y: Int) -> Bool {
        if !city.withinBounds(x: x, y: y) {
            return false
        }
        
        let tile = city.getTile(x: x, y: y)
        return !(tile < TileConstants.ROADBASE && tile > TileConstants.LASTRAIL && tile >= TileConstants.POWERBASE && tile < TileConstants.LASTPOWER)
    }
    
    private func tryDrive() -> Bool {
        lastDir = 5
        positionsStack.removeAll(keepCapacity: false)
        
        for var z = 0; z < MAX_TRAFFIC_DISTANCE; z++ {
            if tryGo(z) && driveDone() {
                return true
            } else {
                if !positionsStack.isEmpty {
                    positionsStack.removeAtIndex(positionsStack.count - 1)
                    z += 3
                } else {
                    return false
                }
            }
        }
        
        return false
    }
    
    private let dX = [0, 1, 0, -1]
    private let dY = [-1, 0, 1, 0]
    
    private func tryGo(z: Int) -> Bool {
        let randomDirection = Int(arc4random_uniform(4))
        for d in randomDirection...(randomDirection + 3) {
            let realDirection = d % 4
            if realDirection == lastDir {
                continue
            }
            
            if isRoadLike(mapX + dX[realDirection], y: mapY + dY[realDirection]) {
                mapX += dX[realDirection]
                mapY += dY[realDirection]
                
                lastDir = (realDirection + 2) % 4
                if z % 2 == 1 {
                    let p = (mapX, mapY)
                    positionsStack.append(p)
                }
                
                return true
            }
        }
        
        return false
    }
    
    private func driveDone() -> Bool {
        var low, high: UInt16
        
        switch sourceZone {
        case .Some(.Residential):
            low = TileConstants.COMBASE
            high = TileConstants.NUCLEAR
            break;
        case .Some(.Commercial):
            low = TileConstants.LHTHR
            high = TileConstants.PORT
            break
        case .Some(.Industrial):
            low = TileConstants.LHTHR
            high = TileConstants.COMBASE
            break
        default: return false
        }
        
        if mapY > 0 {
            let tile = city.getTile(x: mapX, y: mapY - 1)
            if tile >= low && tile <= high {
                return true
            }
        }
        
        if mapX + 1 < city.getWidth() {
            let tile = city.getTile(x: mapX + 1, y: mapY)
            if tile >= low && tile <= high {
                return true
            }
        }
        
        if mapY + 1 < city.getHeight() {
            let tile = city.getTile(x: mapX, y: mapY + 1)
            if tile >= low && tile <= high {
                return true
            }
        }
        
        if mapX > 0 {
            let tile = city.getTile(x: mapX - 1, y: mapY)
            if tile >= low && tile <= high {
                return true
            }
        }
        
        return false
    }
}
