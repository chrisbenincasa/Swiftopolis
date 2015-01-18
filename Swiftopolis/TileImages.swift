//
//  TileImages.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/15/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa
import SpriteKit

private let GlobalTileImages = TileImages()

class TileImages {
    private(set) var spriteByName: [String : SKSpriteNode] = [:]
    
    class var sharedInstance: TileImages {
        return GlobalTileImages
    }
    
    func processTileImages(tile: Tile) {
        for imageName in tile.images {
            let splitString = imageName.componentsSeparatedByString("@")
            if spriteByName[splitString.first!] == nil {
                spriteByName[splitString.first!] = SKSpriteNode(imageNamed: splitString.first!)
            }
        }
    }
    
    func getSpriteForImage(imageName: String) -> SKSpriteNode? {
        let splitString = imageName.componentsSeparatedByString("@")
        
        return splitString.first.map { (str: String) in
            return SKSpriteNode(imageNamed: str)
        }
    }
}
