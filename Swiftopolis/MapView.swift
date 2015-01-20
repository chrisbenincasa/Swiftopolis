//
//  MapView.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/19/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa
import SpriteKit

class MapView : SKView {
    var tileImages = TileImages.instance
    var currentPoint: CGPoint?
    var currentRect: CGRect = CGRect.zeroRect
    let VIEWPORT_WIDTH = 25
    let VIEWPORT_HEIGHT = 25
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer = self.makeBackingLayer()
        self.layer?.delegate = self
//        self.frame.offset(dx: self.frame.width / 2, dy: self.frame.height / 2)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if self.currentPoint == nil {
            self.currentPoint = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        }
        
        println(self.currentPoint)
        
        if let s = scene as? GameScene {
            let city = s.city
            
            var context = NSGraphicsContext.currentContext()!.CGContext
            
            let point = self.currentPoint!
            let halfWidth = Int(city.map.width >> 1)
            let halfHeight = Int(city.map.height >> 1)
                
            let xMin = max(-halfWidth, Int(point.x) - VIEWPORT_WIDTH)
            let xMax = min(halfWidth, Int(point.x) + VIEWPORT_WIDTH)
            let yMin = max(-halfHeight, Int(point.y) - VIEWPORT_HEIGHT)
            let yMax = min(halfHeight, Int(point.y) + VIEWPORT_HEIGHT)
            
            println("\(xMin) \(xMax) -- \(yMin) \(yMax)")
            
            for var y = 0, cameraY = yMin; cameraY < yMax; y++, cameraY++ {
                for var x = 0, cameraX = xMin; cameraX < xMax; x++, cameraX++ {
                    let mapX = cameraX + (city.map.width / 2)
                    let mapY = cameraY + (city.map.height / 2)
                    if let tile = city.map.getTile(x: mapX, y: mapY) {
                        let imageInfo = self.tileImages.getTileImageInfo(Int(tile), acycle: 0)
                        let image = self.tileImages.getImage(imageInfo.imageNumber)
                        let position = CGPoint(x: x * 16, y: y * 16)
                        image.drawAtPoint(position, fromRect: NSRect.zeroRect, operation: .CompositeSourceOver, fraction: 1.0)
                    } else {
                        println("tile not found.")
                    }
                }
            }
            
            CGContextFlush(context)
        }
    }
    
    override func drawLayer(layer: CALayer!, inContext ctx: CGContext!) {
        println("draw layer bitch")
    }
}