//
//  ToolPreview.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/22/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import SpriteKit

class ToolPreview: AbstractToolEffect {

    var offsetX: Int = 0
    var offsetY: Int = 0
    var height: Int {
        return tiles.count
    }
    var width: Int {
        if tiles.count == 0 {
            return 0
        } else {
            return tiles[0].count
        }
    }
    var tiles: [[UInt16]] = []
    private(set) var sounds: [CitySound] = []
    var cost: Int = 0
    var result: ToolResult = .None
    
    // MARK: Implement AbstractToolEffect
    
    func getTile(dx: Int, _ dy: Int) -> UInt16 {
        if inRange(dx, dy) {
            return tiles[offsetY + dy][offsetX + dx]
        } else {
            return TileConstants.CLEAR
        }
    }
    
    func setTile(dx: Int, _ dy: Int, _ tile: UInt16) {
        expandTo(dx, dy)
        tiles[offsetY + dy][offsetX + dx] = tile
    }
    
    func makeSound(dx: Int, _ dy: Int, sound: Sound) {
        sounds.append(CitySound(x: dx, dy, sound: sound))
    }
    
    func spend(amount: Int) {
        cost += amount
    }
    
    // MARK: Helpers
    
    func inRange(dx: Int, _ dy: Int) -> Bool {
        return offsetY + dy >= 0 && offsetY + dy < height && offsetX + dx >= 0 && offsetX + dx < width
    }
    
    func getBounds() -> NSRect {
        return NSRect(x: -offsetX, y: -offsetY, width: width, height: height)
    }
    
    func expandTo(dx: Int, _ dy: Int) {
        if tiles.isEmpty {
            tiles.append([UInt16](arrayLiteral: TileConstants.CLEAR))
            offsetX = -dx
            offsetY = -dy
            return
        }
        
        for tile in tiles {
            if offsetX + dx >= tile.count {
                let newLength = offsetX + dx + 1
                var newArr: [UInt16] = []
                Utils.initializeArray(&newArr, size: newLength, value: TileConstants.CLEAR)
                newArr.replaceRange(0...tile.count, with: tile)
            } else if offsetX + dx < 0 {
                let newLength = tile.count - (offsetX + dx)
                var newArr: [UInt16] = []
                Utils.initializeArray(&newArr, size: newLength, value: TileConstants.CLEAR)
                newArr.replaceRange((offsetX + dx)...tile.count, with: tile)
            }
        }
        
        if offsetX + dx < 0 {
            offsetX += -(offsetX + dx)
        }
        
        let width = tiles[0].count
        if offsetY + dy >= tiles.count {
            let newLength = offsetY + dy + 1
            var newArr: [[UInt16]] = []
            Utils.initializeMatrix(&newArr, width: newLength, height: width, value: TileConstants.CLEAR)
            newArr.replaceRange(0...tiles.count, with: tiles)
            tiles = newArr
        } else if offsetY + dy < 0 {
            let add = -(offsetY + dy)
            let newLength = tiles.count + add
            var newArr: [[UInt16]] = []
            Utils.initializeMatrix(&newArr, width: newLength, height: width, value: TileConstants.CLEAR)
            newArr.replaceRange(add...tiles.count, with: tiles)
            tiles = newArr
            offsetY += add
        }
    }
}