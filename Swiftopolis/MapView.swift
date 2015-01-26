//
//  MapView.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/25/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa

private let INVERT_Y_AXIS = false

class MapView: NSView {
    
    var city: City?
    var currentPoint: CGPoint?
    private let VIEWPORT_WIDTH = 25  // viewport width in tiles
    private let VIEWPORT_HEIGHT = 25 // viewport height in tiles
    private var tileSize: Int = 16   // Tile size in pixels
    private var tileImages: TileImages!
    
    init(tileSize: Int, frame: NSRect) {
        super.init(frame: frame)
        self.tileSize = tileSize
        self.tileImages = TileImages.instance(tileSize)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tileImages = TileImages.instance(tileSize)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if self.currentPoint == nil {
            self.currentPoint = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        }
        
        if let c = self.city {
            var context = NSGraphicsContext.currentContext()!.CGContext
            
            let point = self.currentPoint!
            let halfWidth = Int(c.map.width >> 1)
            let halfHeight = Int(c.map.height >> 1)
            
            let xMin = max(-halfWidth, Int(point.x) - VIEWPORT_WIDTH)
            let xMax = min(halfWidth, Int(point.x) + VIEWPORT_WIDTH)
            let yMin = max(-halfHeight, Int(point.y) - VIEWPORT_HEIGHT)
            let yMax = min(halfHeight, Int(point.y) + VIEWPORT_HEIGHT)
            
            // for var y = 0, cameraY = yMax - 1; cameraY >= yMin; y++, cameraY-- { // inverted Y axis
            for var y = 0, cameraY = yMin; cameraY < yMax; y++, cameraY++ {
                for var x = 0, cameraX = xMin; cameraX < xMax; x++, cameraX++ {
                    // Camera positions have (0, 0) at the center of the map while
                    let (mapX, mapY) = cameraPositionToMapPosition(c, cameraX, cameraY)
                    if let tile = c.map.getTile(x: mapX, y: mapY) {
                        let imageInfo = self.tileImages.getTileImageInfo(Int(tile), acycle: 0)
                        let image = self.tileImages.getImage(imageInfo.imageNumber)
                        let position = CGPoint(x: x * tileSize, y: y * tileSize)
                        image.drawAtPoint(position, fromRect: NSRect.zeroRect, operation: .CompositeSourceOver, fraction: 1.0)
                    } else {
                        println("tile not found. \(mapX, mapY)")
                    }
                }
            }
            
            CGContextFlush(context)
        }
    }
    
    private func cameraPositionToMapPosition(city: City, _ x: Int, _ y: Int, invertedY: Bool = INVERT_Y_AXIS) -> (Int, Int) {
        let mapX = x + (city.map.width / 2)
        
        if invertedY {
            return (mapX, y + (city.map.height / 2))
        } else {
            return (mapX, city.map.height - (y + (city.map.height / 2)) - 1)
        }
    }

}