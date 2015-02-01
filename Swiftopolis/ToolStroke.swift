//
//  ToolStroke.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

class ToolStroke {

    private(set) var city: City
    var xSrc: Int
    var ySrc: Int
    var xDest: Int
    var yDest: Int
    private(set) var tool: Tool
    private(set) var previewing: Bool = false
    
    private var currentEffect: ToolEffect?
    
    init(city: City, tool: Tool, x: Int, y: Int) {
        self.city = city
        self.tool = tool
        self.xSrc = x
        self.xDest = x
        self.ySrc = y
        self.yDest = y
    }
    
    func getPreview() -> ToolPreview {
        let effect = ToolEffect(city: city)
        
        previewing = true
        applyArea(effect)
        previewing = false
        return effect.preview
    }
    
    func dragTo(x: Int, _ y: Int) {
        xDest = x
        yDest = y
    }
    
    func apply() -> ToolResult {
        let effect = ToolEffect(city: city)
        applyArea(effect)
        return effect.apply()
    }
    
    func applyArea(effect: AbstractToolEffect) {
        let toolSize = tool.size()
        let bounds = getBounds()
        
        for var i = 0; i < Int(bounds.height); i += toolSize {
            for var j = 0; j < Int(bounds.width); j += toolSize {
                applyWithEffect(OffsetToolEffect(base: effect, dx: Int(bounds.origin.x) + j, dy: Int(bounds.origin.y) + i))
            }
        }
    }
    
    func applyWithEffect(effect: AbstractToolEffect) -> Bool {
        var tile: UInt16!
        
        switch tool {
        case .Park: return false
        case .Residential:
            tile = TileConstants.RESCLR
            break
        case .Commercial:
            tile = TileConstants.COMCLR
            break
        case .Industrial:
            tile = TileConstants.INDCLR
            break
        default: fatalError("Unexpected tool \(tool)")
        }
        
        return applyZone(effect, Tiles.load(Int(tile)))
    }
    
    func getBounds() -> CGRect {
        let toolSize = tool.size()
        var x: Int = self.xSrc, y: Int = self.ySrc, width: Int, height: Int
        
        if toolSize >= 3 {
            x -= 1
        }
        
        if xDest >= xSrc {
            width = ((xDest - xSrc) / toolSize + 1) * toolSize
        } else {
            width = ((xDest - xSrc) / toolSize + 1) * toolSize
            x += toolSize - width
        }
        
        if toolSize >= 3 {
            y -= 1
        }
        
        if yDest >= ySrc {
            height = ((yDest - ySrc) / toolSize + 1) * toolSize
        } else {
            height = ((yDest - ySrc) / toolSize + 1) * toolSize
            y += toolSize - height
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func getLocation() -> CityLocation {
        return CityLocation(x: self.xSrc, y: self.ySrc)
    }
    
    func applyZone(effect: AbstractToolEffect, _ base: Tile) -> Bool {
        if let buildingInfo = base.buildingInfo {
            var cost = tool.cost()
            var canBuild = true
            for row in 0..<buildingInfo.height {
                for col in 0..<buildingInfo.width {
                    let tile = effect.getTile(col, row)
                    if tile == TileConstants.CLEAR || (tile & TileConstants.LOMASK) != TileConstants.DIRT {
                        let t = tile & TileConstants.LOMASK
                        if city.autoBulldoze && TileConstants.canAutoBulldozeZone(t) {
                            cost++
                        } else {
                            canBuild = false
                        }
                    }
                }
            }
            
            if !canBuild {
                // TODO set effect result
                return false
            }
            
            effect.spend(cost)
            
            var i = 0
            for row in 0..<buildingInfo.height {
                for col in 0..<buildingInfo.width {
                    effect.setTile(col, row, buildingInfo.members[i].tileNumber)
                    i++
                }
            }
            
            fixBorder(effect, buildingInfo.width, buildingInfo.height)
            
            return true
        } else {
            fatalError("Canont applyZone to #\(base.tileNumber)")
        }
    }
    
    internal func fixBorder(effect: AbstractToolEffect, _ width: Int, _ height: Int) {
        for x in 0..<width {
            fixZone(OffsetToolEffect(base: effect, dx: x, dy: 0))
            fixZone(OffsetToolEffect(base: effect, dx: x, dy: height - 1))
        }
        
        for y in 1..<height - 1 {
            fixZone(OffsetToolEffect(base: effect, dx: 0, dy: y))
            fixZone(OffsetToolEffect(base: effect, dx: width - 1, dy: y))
        }
    }
    
    internal func fixZone(effect: AbstractToolEffect) {
        fixSingleTile(effect)
        
        fixSingleTile(OffsetToolEffect(base: effect, dx: 0, dy: -1))
        fixSingleTile(OffsetToolEffect(base: effect, dx: -1, dy: 0))
        fixSingleTile(OffsetToolEffect(base: effect, dx: 1, dy: 0))
        fixSingleTile(OffsetToolEffect(base: effect, dx: 0, dy: 1))
    }
    
    // Fixes dynamic road, rail, power tiles if necessary
    internal func fixSingleTile(effect: AbstractToolEffect) {
        let tile = effect.getTile(0, 0)
        
        if TileConstants.isDynamicRoad(tile) {
            var adjTile = 0
            
            // North
            if TileConstants.roadConnectsVertically(effect.getTile(0, -1)) {
                adjTile |= 1
            }
            
            // East
            if TileConstants.roadConnectsHorizontally(effect.getTile(1, 0)) {
                adjTile |= 2
            }
            
            // South
            if TileConstants.roadConnectsVertically(effect.getTile(0, 1)) {
                adjTile |= 4
            }
            
            // West
            if TileConstants.roadConnectsHorizontally(effect.getTile(-1, 0)) {
                adjTile |= 8
            }
            
            effect.setTile(0, 0, TileConstants.RoadTable[adjTile])
        } else if TileConstants.isDynamicRoad(tile) {
            var adjTile = 0
            
            // North
            if TileConstants.railConnectsVertically(effect.getTile(0, -1)) {
                adjTile |= 1
            }
            
            // East
            if TileConstants.railConnectsHorizontally(effect.getTile(1, 0)) {
                adjTile |= 2
            }
            
            // South
            if TileConstants.railConnectsVertically(effect.getTile(0, 1)) {
                adjTile |= 4
            }
            
            // West
            if TileConstants.railConnectsHorizontally(effect.getTile(-1, 0)) {
                adjTile |= 8
            }
            
            effect.setTile(0, 0, TileConstants.RailTable[adjTile])
        } else if TileConstants.isDynamicWire(tile) {
            var adjTile = 0
            
            // North
            if TileConstants.powerConnectsVertically(effect.getTile(0, -1)) {
                adjTile |= 1
            }
            
            // East
            if TileConstants.powerConnectsHorizontally(effect.getTile(1, 0)) {
                adjTile |= 2
            }
            
            // South
            if TileConstants.powerConnectsVertically(effect.getTile(0, 1)) {
                adjTile |= 4
            }
            
            // West
            if TileConstants.powerConnectsHorizontally(effect.getTile(-1, 0)) {
                adjTile |= 8
            }
            
            effect.setTile(0, 0, TileConstants.WireTable[adjTile])
        }
    }
}
