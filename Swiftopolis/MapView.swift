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
    
    private(set) var city: City!
    lazy var currentMapPoint: CGPoint = {
        [unowned self] in return CGPoint(x: self.city.map.width / 2, y: self.city.map.height / 2)
    }()
    
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
    
    init(tileSize: Int, city: City, frame: NSRect) {
        super.init(frame: frame)
        self.city = city
        self.tileSize = tileSize
        self.tileImages = TileImages.instance(tileSize)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tileImages = TileImages.instance(tileSize)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if city == nil {
            return
        }
        
        var context = NSGraphicsContext.currentContext()!.CGContext
        
        let viewPoint = mapPointToViewPoint(self.currentMapPoint)
        
        var point = normalizeWorldPoint(viewPoint)
        
        let xMin = Int(point.x) - (VIEWPORT_WIDTH >> 1)
        let xMax = Int(point.x) + (VIEWPORT_WIDTH >> 1)
        let yMin = Int(point.y) - (VIEWPORT_HEIGHT >> 1)
        let yMax = Int(point.y) + (VIEWPORT_HEIGHT >> 1)
        
//        println("xMin = \(xMin), yMin = \(yMin), xMax = \(xMax), yMax = \(yMax)")
        // for var y = 0, cameraY = yMax - 1; cameraY >= yMin; y++, cameraY-- { // inverted Y axis
        for var y = 0, cameraY = yMin; cameraY < yMax; y++, cameraY++ {
            for var x = 0, cameraX = xMin; cameraX < xMax; x++, cameraX++ {
                // Camera positions have (0, 0) at the center of the map while
                let (mapX, mapY) = cameraPositionToMapPosition(cameraX, cameraY)
                if let tile = city.map.getTile(x: mapX, y: mapY) {
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
    
    private func cameraPositionToMapPosition(x: Int, _ y: Int, invertedY: Bool = INVERT_Y_AXIS) -> (Int, Int) {
        let mapX = x + (city.map.width / 2)
        
        if invertedY {
            return (mapX, y + (city.map.height / 2))
        } else {
            return (mapX, city.map.height - (y + (city.map.height / 2)) - 1)
        }
    }

    private func mapPointToViewPoint(point: CGPoint) -> CGPoint {
        return CGPoint(x: Int(point.x) - (city.map.width / 2), y: (city.map.height / 2) - Int(point.y))
    }
    
    private func viewPointToMapPoint(point: CGPoint) -> CGPoint {
        return CGPoint(x: Int(point.x) + (city.map.width / 2), y: (city.map.height / 2) - Int(point.y))
    }
    
    private func normalizeWorldPoint(var point: CGPoint) -> CGPoint {
        let halfVewportWidth = VIEWPORT_WIDTH >> 1   // Ints round down
        let halfVewportHeight = VIEWPORT_HEIGHT >> 1 // Ints round down
        let halfWidth = city.map.width >> 1
        let halfHeight = city.map.height >> 1

        
        if Int(point.x) <= -(halfWidth - halfVewportWidth) {
            point.x = -CGFloat(halfWidth - halfVewportWidth)
        } else if Int(point.x) > (halfWidth - halfVewportWidth) {
            point.x = CGFloat(halfWidth - halfVewportWidth)
        }
        
        if Int(point.y) <= -(halfHeight - halfVewportHeight) {
            point.y = -CGFloat(halfHeight - halfVewportHeight)
        } else if Int(point.y) > (halfHeight - halfVewportHeight) {
            point.y = CGFloat(halfHeight - halfVewportHeight)
        }
        
        return point
    }
}