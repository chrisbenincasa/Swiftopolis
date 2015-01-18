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
    
    func processTile(tile: RawType) -> Tile
}

class TileJsonLoader: TileLoader {
    func readTiles(path: String) {
        if let data: NSData = NSFileManager.defaultManager().contentsAtPath(path) {
            let json = JSON(data: data)
            for (_, subJson: JSON) in json {
                let tile = processTile(subJson)
//                TileImages.sharedInstance.processTileImages(tile)
            }
            
            println("Loaded \(Tiles.sharedInstance.tiles.count) tiles.")
        }
    }
    
    func processTile(tile: JSON) -> Tile {
        let tileNumber = UInt16(tile["number"].int!)
        let tileName = tile["name"].string!
        
        let t = Tile(tileNumber: tileNumber, tileName: tileName)
        let rawDict = tile.dictionaryObject
        if let images = rawDict?["images"] as? [String] {
            t.images = images
            TileImages.sharedInstance.processTileImages(t)
        }
        
        if let flammable = rawDict?["flammable"] as? Bool {
            t.canBurn = flammable
        } else {
            t.canBurn = false
        }
        
        Tiles.sharedInstance.tilesByName.updateValue(t, forKey: tileName)
        Tiles.sharedInstance.tiles.append(t)
        
        return t
    }
}