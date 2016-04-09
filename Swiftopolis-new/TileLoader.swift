//
//  TileLoader.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa
import SwiftyJSON

protocol TileLoader {
    associatedtype RawType
    
    func readTiles(path: String) -> Void
    
    func processTile(tile: RawType) -> Tile
}

class TileJsonLoader: TileLoader {
    func readTiles(path: String) {
        if let data: NSData = NSFileManager.defaultManager().contentsAtPath(path) {
            let json = JSON(data: data)
            for (_, subJson): (String, JSON) in json {
                processTile(subJson)
            }
        }
        
        Tiles.sharedInstance.tiles.foreach(resolveTileReferences)
    }
    
    func processTile(tile: JSON) -> Tile {
        let tileNumber = UInt16(tile["number"].int!)
        let tileName = tile["name"].string!
        
        let t = Tile(tileNumber: tileNumber, tileName: tileName)
        
        if let images = tile["images"].arrayObject as? [String] {
            t.images = images
        }
        
        t.canBurn = tile["flammeable"].bool.getOrElse(false)
        t.canBulldoze = tile["bulldozable"].bool.getOrElse(false)
        t.canConduct = tile["conducts"].bool.getOrElse(false)
        t.overWater = tile["overWater"].bool.getOrElse(false)
        t.isZone = tile["zone"].bool.getOrElse(false)
        if let ownerNumber = tile["owner"].int {
            t.ownerTileNumber = ownerNumber
            t.ownerOffsetX = tile["ownerOffsetX"].int
            t.ownerOffsetY = tile["ownerOffsetY"].int
        }
        t.nextAnimationTile = tile["animNext"].int
        t.onPower = tile["onPower"].int
        t.onShutdown = tile["onShutdown"].int
        
        let rawAttributes = (tile["attributes"].dictionaryObject as? [String:[String]]).getOrElse([:])
        var tileAttributes: [String:String] = [:]
        
        for (key, value) in rawAttributes {
            if value.count > 0 {
                tileAttributes[key] = value.first!
            }
        }
        
        t.attributes = tileAttributes
        
        let buildingWidth = tile["buildingInfo"]["width"][0].int
        let buildingHeight = tile["buildingInfo"]["height"][0].int
        let buildingMembers = tile["buildingInfo"]["members"][0].arrayObject as? [Int]
        
        if buildingWidth != nil && buildingHeight != nil && buildingMembers != nil {
            let buildingInfo = BuildingInfo(width: buildingWidth!, height: buildingHeight!, memberTileNumbers: buildingMembers!, members: [])
            t.buildingInfo = buildingInfo
        } else if tile["buildingInfo"] != nil {
            print("width = \(buildingWidth), height = \(buildingHeight), members = \(buildingMembers)")
            print("nil stuff but building info isn't nil")
        }
        
        Tiles.sharedInstance.tilesByName.updateValue(t, forKey: tileName)
        Tiles.sharedInstance.tiles.append(t)
        
        return t
    }
    
    func resolveTileReferences(tile: Tile) {
        if let ownerNumber = tile.ownerTileNumber {
            tile.owner = Tiles.load(ownerNumber)
        }
        
        if var buildingInfo = tile.buildingInfo {
            for num in buildingInfo.memberTileNumbers {
                buildingInfo.members.append(Tiles.load(num))
            }
            
            tile.buildingInfo = buildingInfo
        }
    }
}