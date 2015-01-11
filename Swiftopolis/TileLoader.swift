//
//  TileLoader.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

protocol TileLoader {
    typealias RawType
    
    func readTiles(path: String) -> Void
    
    func processTile(tile: RawType) -> Void
}

class TileJsonLoader: TileLoader {
    func readTiles(path: String) {
        if let data: NSData = NSFileManager.defaultManager().contentsAtPath(path) {
            let json = JSON(data: data)
            for (_, subJson: JSON) in json {
                processTile(subJson)
            }
            
            println(Tiles.sharedInstance.tiles.count)
        }
    }
    
    func processTile(tile: JSON) {
        let tileNumber = UInt16(tile["number"].int!)
        let tileName = tile["name"].string!
        
        let t = Tile(tileNumber: tileNumber, tileName: tileName)
        
        Tiles.sharedInstance.tilesByName.updateValue(t, forKey: tileName)
        Tiles.sharedInstance.tiles.append(t)
    }
}