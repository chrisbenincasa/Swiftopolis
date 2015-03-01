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
    
    private var animatedTiles: [CGPoint] = []
    private var blinkingTiles: [CGPoint] = []
    
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
        // Get the current visible rectangle based off of the current center point and viewport size
        let generatedViewport = engine.mapRectForViewport(CGSize(width: VIEWPORT_WIDTH, height: VIEWPORT_HEIGHT))
        
        let origin = generatedViewport.origin +- (dirtyRect.origin / tileSize)
        let size = dirtyRect.size / tileSize
        let dRect = CGRect(origin: origin, size: size)
        let minXPoint = Int(dRect.minX)
        let minYPoint = max(0, Int(dRect.origin.y - dRect.height))
        let maxXPoint = Int(dRect.maxX)
        let maxYPoint = Int(dRect.origin.y)
        
        // for var y = 0, cameraY = yMax - 1; cameraY >= yMin; y++, cameraY-- { // inverted Y axis
        for var y = 0, cameraY = minYPoint; cameraY < maxYPoint; y++, cameraY++ {
            for var x = 0, cameraX = minXPoint; cameraX < maxXPoint; x++, cameraX++ {
                // Camera positions have (0, 0) at the center of the map while
                let (mapX, mapY) = (cameraX, cameraY)
                if !engine.city.withinBounds(x: mapX, y: mapY) {
                    continue
                }
                if var tile = engine.city.map.getTile(x: mapX, y: mapY) {
                    if TileConstants.isZoneCenter(tile) && !engine.city.isTilePowered(x: mapX, y: mapY) {
                        tile = TileConstants.LIGHTNINGBOLT
                    }
                    
                    if let currentPreview = engine.toolPreview {
                        let t = currentPreview.getTile(mapX, mapY)
                        if t != TileConstants.CLEAR {
                            tile = t
                        }
                    }
                    
                    let imageInfo = self.tileImages.getTileImageInfo(Int(tile), acycle: engine.city.getAnimationCycle())
                    let image = self.tileImages.getImage(imageInfo.imageNumber)
                    
                     // Calculate the draw position (bottom left) of the tile
                    // (y + 1) to adjust for bottom vs. top
                    let xDrawPosition = Int(dirtyRect.origin.x) + (x * tileSize)
                    let yDrawPosition = Int(dirtyRect.origin.y) + Int(dirtyRect.height) - ((y + 1) * tileSize)
                    let position = CGPoint(x: xDrawPosition, y: yDrawPosition)
                    image.drawAtPoint(position, fromRect: NSRect.zeroRect, operation: .CompositeSourceOver, fraction: 1.0)
                    
                    if imageInfo.animated {
                        self.animatedTiles.append(CGPoint(x: mapX, y: mapY))
                    }
                } else {
                    println("tile not found. \(mapX, mapY)")
                }
            }
        }
    }
    
    func getViewport() -> NSRect {
        let point = normalizeMapPoint(engine.currentMapPoint)
        let size = CGSizeMake(CGFloat(VIEWPORT_WIDTH), CGFloat(VIEWPORT_HEIGHT))
        return NSRect(origin: point, size: size)
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