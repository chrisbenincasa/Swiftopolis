//
//  BulldozerTool.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/24/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

class BulldozerTool: ToolStroke {
    convenience init(city: City, x: Int, y: Int) {
        self.init(city: city, tool: .Bulldozer, x: x, y: y)
    }
    
    override func applyArea(effect: AbstractToolEffect) {
        let bounds = getBounds()
        
        for var y = 0; y < Int(bounds.height); y++ {
            for var x = 0; x < Int(bounds.width); x++ {
                let e = OffsetToolEffect(base: effect, dx: Int(bounds.origin.x) + x, dy: Int(bounds.origin.y) + y)
                
                if city.isTileBulldozable(e) {
                    bulldozeField(e)
                }
                
                let tile = UInt16(effect.getTile(Int(bounds.origin.x) + x, Int(bounds.origin.y) + y))
                if TileConstants.isZoneCenter(tile) {
                    bulldozeZone(e)
                }
            }
        }
        
        
    }
    
    private func bulldozeField(effect: AbstractToolEffect) {
        let tile = UInt16(effect.getTile(0, 0))

        if TileConstants.isOverWater(tile) {
            effect.setTile(0, 0, TileConstants.RIVER)
        } else {
            effect.setTile(0, 0, TileConstants.DIRT)
        }
        
        fixZone(effect)
        effect.spend(1)
    }
    
    private func bulldozeZone(effect: AbstractToolEffect) {
        let tile = UInt16(effect.getTile(0, 0))
        
        if let dimensions = TileConstants.getZoneSizeFor(tile) {
            assert(dimensions.width >= 3 && dimensions.height >= 3, "zone size < 3")
            
            effect.spend(1)
            
            if dimensions.width * dimensions.height < 16 {
                effect.makeSound(0, 0, sound: ExplosionSound(isHigh: true))
            } else if dimensions.width * dimensions.height < 36 {
                effect.makeSound(0, 0, sound: ExplosionSound())
            } else {
                effect.makeSound(0, 0, sound: ExplosionSound())
            }
        } else {
            fatalError("Unable to get dimensions for zone!!")
        }
    }
    
    private func putRubble(effect: AbstractToolEffect, _ w: Int, _ h: Int) {
        for y in 0..<h {
            for x in 0..<w {
                let tile = effect.getTile(x, y)
                if tile == TileConstants.CLEAR {
                    continue
                }
                
                if UInt16(tile) != TileConstants.RADTILE && UInt16(tile) != TileConstants.DIRT {
                    let z = previewing ? 0 : Int(arc4random_uniform(3))
                    let nTile = TileConstants.TINYEXP + UInt16(z)
                    effect.setTile(x, y, nTile)
                }
            }
        }
        
        fixBorder(effect, w, h)
    }
}