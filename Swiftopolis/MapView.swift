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
    
    private(set) var engine: Engine!
    
    private var VIEWPORT_WIDTH: Int {
        get {
            return Int(self.frame.width) / self.tileSize
        }
    }
    private var VIEWPORT_HEIGHT: Int {
        get {
            return Int(self.frame.height) / self.tileSize
        }
    }
    private(set) var tileSize: Int = 16   // Tile size in pixels
    private var tileImages: TileImages!
    
    init(tileSize: Int, engine: Engine, frame: NSRect) {
        super.init(frame: frame)
        self.engine = engine
        self.tileSize = tileSize
        self.tileImages = TileImages.instance(tileSize)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tileImages = TileImages.instance(tileSize)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if dirtyRect == frame {
            println("request to draw entire frame")
            drawEntireMap()
        } else {
            // TODO: optimize drawing when we don't have to redraw the entire frame
            drawPortionOfMap(dirtyRect)
        }
    }
    
    func getViewport() -> NSRect {
        let point = normalizeMapPoint(engine.currentMapPoint)
        let size = CGSizeMake(CGFloat(VIEWPORT_WIDTH), CGFloat(VIEWPORT_HEIGHT))
        return NSRect(origin: point, size: size)
    }
    
    private func drawEntireMap() {
        var context = NSGraphicsContext.currentContext()!.CGContext
        
        let viewPoint = mapPointToViewPoint(engine.currentMapPoint)
        
        var point = normalizeWorldPoint(viewPoint)
        
        let xMin = Int(point.x) - (VIEWPORT_WIDTH >> 1)
        let xMax = Int(point.x) + (VIEWPORT_WIDTH >> 1)
        let yMin = Int(point.y) - (VIEWPORT_HEIGHT >> 1)
        let yMax = Int(point.y) + (VIEWPORT_HEIGHT >> 1)
        
        // for var y = 0, cameraY = yMax - 1; cameraY >= yMin; y++, cameraY-- { // inverted Y axis
        for var y = 0, cameraY = yMin; cameraY < yMax; y++, cameraY++ {
            for var x = 0, cameraX = xMin; cameraX < xMax; x++, cameraX++ {
                // Camera positions have (0, 0) at the center of the map while
                let (mapX, mapY) = cameraPositionToMapPosition(cameraX, cameraY)
                if !engine.city.withinBounds(x: mapX, y: mapY) {
                    continue
                }
                if let tile = engine.city.map.getTile(x: mapX, y: mapY) {
                    let imageInfo = self.tileImages.getTileImageInfo(Int(tile), acycle: 0)
                    let image = self.tileImages.getImage(imageInfo.imageNumber)
                    let position = CGPoint(x: x * tileSize, y: y * tileSize)
                    image.drawAtPoint(position, fromRect: NSRect.zeroRect, operation: .CompositeSourceOver, fraction: 1.0)
                } else {
                    println("tile not found. \(mapX, mapY)")
                }
            }
        }
    }
    
    private func drawPortionOfMap(rect: NSRect) {
        
    }
    
    private func cameraPositionToMapPosition(x: Int, _ y: Int, invertedY: Bool = INVERT_Y_AXIS) -> (Int, Int) {
        let mapX = x + (engine.city.map.width / 2)
        
        if invertedY {
            return (mapX, y + (engine.city.map.height / 2))
        } else {
            return (mapX, engine.city.map.height - (y + (engine.city.map.height / 2)) - 1)
        }
    }

    private func mapPointToViewPoint(point: CGPoint) -> CGPoint {
        return CGPoint(x: Int(point.x) - (engine.city.map.width / 2), y: (engine.city.map.height / 2) - Int(point.y))
    }
    
    private func viewPointToMapPoint(point: CGPoint) -> CGPoint {
        return CGPoint(x: Int(point.x) + (engine.city.map.width / 2), y: (engine.city.map.height / 2) - Int(point.y))
    }
    
    private func normalizeWorldPoint(var point: CGPoint) -> CGPoint {
        let halfViewportWidth = VIEWPORT_WIDTH >> 1   // Ints round down
        let halfViewportHeight = VIEWPORT_HEIGHT >> 1 // Ints round down
        let halfWidth = engine.city.map.width >> 1
        let halfHeight = engine.city.map.height >> 1

        if Int(point.x) <= -(halfWidth - halfViewportWidth) {
            point.x = -CGFloat(halfWidth - halfViewportWidth)
        } else if Int(point.x) > (halfWidth - halfViewportWidth) {
            point.x = CGFloat(halfWidth - halfViewportWidth)
        }
        
        if Int(point.y) <= -(halfHeight - halfViewportHeight) {
            point.y = -CGFloat(halfHeight - halfViewportHeight)
        } else if Int(point.y) > (halfHeight - halfViewportHeight) {
            point.y = CGFloat(halfHeight - halfViewportHeight)
        }
        
        return point
    }
    
    private func normalizeMapPoint(var point: CGPoint) -> CGPoint {
        let halfViewportWidth = VIEWPORT_WIDTH >> 1   // Ints round down
        let halfViewportHeight = VIEWPORT_HEIGHT >> 1 // Ints round down
        let halfWidth = engine.city.map.width >> 1
        let halfHeight = engine.city.map.height >> 1
        
        if Int(point.x) - halfViewportWidth < 0 {
            point.x = CGFloat(halfViewportWidth)
        } else if Int(point.x) + halfViewportWidth > engine.city.map.width {
            point.x = CGFloat(engine.city.map.width - halfViewportWidth)
        }
        
        if Int(point.y) - halfViewportHeight < 0 {
            point.y = CGFloat(halfViewportHeight)
        } else if Int(point.y) + halfViewportHeight > engine.city.map.height {
            point.y = CGFloat(engine.city.map.height - halfViewportHeight)
        }
        
        return point
    }
}