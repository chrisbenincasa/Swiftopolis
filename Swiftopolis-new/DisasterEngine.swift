//
//  DisasterEngine.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/11/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

internal class DisasterEngine {
    private var city: City
    
    init(city: City) {
        self.city = city
    }

    func setFire() -> CityLocation? {
        let (x, y) = randomMapLocation()
        
        if let t = city.map.getTile(x: x, y: y) {
            if TileConstants.isArsonable(t) {
                city.setTile(x: x, y: y, tile: TileConstants.FIRE)
                return CityLocation(x: x, y: y)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func makeFlood() -> CityLocation? {
        let dx = [0, 1, 0, -1]
        let dy = [-1, 0, 1, 0]
        
        for var z = 0; z < 300; z++ {
            let (x, y) = randomMapLocation()
            let tile = city.getTile(x: x, y: y)
            if TileConstants.isRiverEdge(tile) {
                for var t = 0; t < 4; t++ {
                    let xx = x + dx[t]
                    let yy = y + dy[t]
                    if city.withinBounds(x: xx, y: yy) {
                        let rawTile = city.map.getRawTile(x: xx, y: yy)
                        if TileConstants.isFloodable(rawTile!) {
                            city.setTile(x: xx, y: yy, tile: TileConstants.FLOOD)
                            return CityLocation(x: xx, y: yy)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    func makeTornado() -> TornadoSprite {
        let (x, y) = randomMapLocation()
        let tornado = TornadoSprite(city: self.city)
        tornado.setCityLocation(CityLocation(x: x, y: y))
        return tornado
    }
    
    func makeEarthquake() {
        let time = arc4random_uniform(701) + 300
        for z in 0 ..< time {
            let (x, y) = randomMapLocation()
            if TileConstants.isVulnerable(city.getTile(x: x, y: y)) {
                if arc4random_uniform(4) != 0 {
                    city.setTile(x: x, y: y, tile: TileConstants.RUBBLE + UInt16(arc4random_uniform(4)))
                } else {
                    city.setTile(x: x, y: y, tile: TileConstants.FIRE)
                }
            }
        }
    }
    
    func makeMonster() -> MonsterSprite {
        for _ in 0 ..< 300 {
            let (x, y) = randomMapLocation()
            if city.getTile(x: x, y: y) == TileConstants.RIVER {
                let monster = MonsterSprite(city: self.city)
                monster.setCityLocation(CityLocation(x: x, y: y))
                return monster
            }
        }
        
        let monster = MonsterSprite(city: self.city)
        monster.setCityLocation(CityLocation(x: city.map.width / 2, y: city.map.height / 2))
        return monster
    }
    
    private func randomMapLocation() -> (Int, Int) {
        let x = Int(arc4random_uniform(UInt32(city.map.width)))
        let y = Int(arc4random_uniform(UInt32(city.map.height)))
        
        return (x, y)
    }
}
