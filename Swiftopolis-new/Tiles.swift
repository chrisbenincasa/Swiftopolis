//
//  Tiles.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

private let GlobalTiles = Tiles()

class Tiles {
    lazy var tiles: [Tile] = []
    lazy var tilesByName: [String : Tile] = [:]
    
    class var sharedInstance: Tiles {
        return GlobalTiles
    }
    
    class func get(idx: Int) -> Tile? {
        if idx < sharedInstance.tiles.count {
            return sharedInstance.tiles[idx]
        } else {
            return nil
        }
    }
    
    class func get(idx: UInt16) -> Tile? {
        return get(Int(idx))
    }
    
    class func load(tileNumber: Int) -> Tile {
        return sharedInstance.tilesByName[String(tileNumber)]!
    }
    
    class func load(tileName: String) -> Tile {
        return sharedInstance.tilesByName[tileName]!
    }
    
    class func getTile(tileNumber: Int) -> Tile? {
        if tileNumber >= 0 && tileNumber < sharedInstance.tiles.count {
            return sharedInstance.tiles[tileNumber]
        } else {
            return nil
        }
    }
    
    class func getTileCount() -> Int {
        return sharedInstance.tiles.count
    }
}
