//
//  ToolEffect.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

class ToolEffect: AbstractToolEffect {

    var city: City
    var preview: ToolPreview!
    var originX: Int
    var originY: Int
    
    init(city: City, xPos: Int, yPos: Int) {
        self.city = city
        self.preview = ToolPreview()
        self.originX = xPos
        self.originY = yPos
    }
    
    convenience init(city: City) {
        self.init(city: city, xPos: 0, yPos: 0)
    }
    
    // MARK: Implement AbstractToolEffect
    
    func getTile(dx: Int, _ dy: Int) -> UInt16 {
        let tile = preview.getTile(dx, dy)
        if tile != TileConstants.CLEAR {
            return tile
        }
        
        if city.withinBounds(x: originX + dx, y: originY + dy) {
            return city.getTile(x: originX + dx, y: originY + dy)
        } else {
            return TileConstants.DIRT
        }
    }
    
    func setTile(dx: Int, _ dy: Int, _ tile: UInt16) {
        preview.setTile(dx, dy, tile)
    }
    
    func makeSound(dx: Int, _ dy: Int, sound: Sound) {
        preview.makeSound(dx, dy, sound: sound)
    }
    
    func spend(amount: Int) {
        preview.spend(amount)
    }
    
    func apply() -> ToolResult {
        if originX - preview.offsetX < 0 ||
            originY - preview.offsetY < 0 ||
            originX + preview.offsetX > city.getWidth() ||
            originY + preview.offsetY > city.getHeight() {
                
                return .InvalidPosition
        }
        
        if city.budget.totalFunds < preview.cost {
            return .InsufficientFunds
        }
        
        var newTileSet = false
        for var y = 0; y < preview.tiles.count; y++ {
            for var x = 0; x < preview.tiles[y].count; x++ {
                let tile = preview.tiles[y][x]
                if tile != TileConstants.CLEAR {
                    println("x: \(originX + x - preview.offsetX), y: \(originY + y - preview.offsetY)")
                    city.setTile(x: originX + x - preview.offsetX, y: originY + y - preview.offsetY, tile: tile)
                    newTileSet = true
                }
            }
        }
        
        for sound in preview.sounds {
//            city
        }
        
        if newTileSet && preview.cost != 0 {
            city.spend(preview.cost)
            return .Success
        } else {
            return preview.result
        }
    }
}
