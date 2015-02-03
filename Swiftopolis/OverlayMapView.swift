//
//  OverlayMapView.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/26/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa

class OverlayMapView: NSView {
    
    var engine: Engine!
    var connectedView: MainSceneView!
    
    private var city: City {
        get {
            return engine.city
        }
    }
    
    private let tileSize = 3
    private var tileImages: TileImages!
    private var mapState: MapState = .All
    
    init(engine: Engine, frame: NSRect) {
        super.init(frame: frame)
        self.engine = engine
        self.tileImages = TileImages.instance(tileSize)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tileImages = TileImages.instance(tileSize)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let localPoint = convertPoint(theEvent.locationInWindow, fromView: nil)
        let mapPoint = CGPoint(x: Int(localPoint.x) / tileSize, y: city.map.height - Int(localPoint.y) / tileSize)
        moveViewTo(mapPoint)
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let localPoint = convertPoint(theEvent.locationInWindow, fromView: nil)
        let mapPoint = CGPoint(x: Int(localPoint.x) / tileSize, y: city.map.height - Int(localPoint.y) / tileSize)
        moveViewTo(mapPoint)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        var context = NSGraphicsContext.currentContext()!.CGContext
        
        let maxY = city.map.height / tileSize
        let maxX = city.map.width / tileSize
        for var y = 0; y < city.map.height; y++ {
            for var x = 0; x < city.map.width; x++ {
                // Map coordinate-system has (0, 0) in the top-left while NSRect coordinate
                // system has (0, 0) in the bottom-left
                let mapY = city.map.height - (y + 1)
                var tile = city.getTile(x: x, y: mapY)
                switch mapState {
                case .Residential:
                    if TileConstants.isZone(tile) && !TileConstants.isResidentialZoneAny(tile) {
                        tile = TileConstants.DIRT
                    }
                    break
                case .Commercial:
                    if TileConstants.isZone(tile) && !TileConstants.isCommercialZone(tile) {
                        tile = TileConstants.DIRT
                    }
                    break
                case .Industrial:
                    if TileConstants.isZone(tile) && !TileConstants.isIndustrialZone(tile) {
                        tile = TileConstants.DIRT
                    }
                    break
                default: break
                }
                
                if tile != UInt16.max {
                    drawTileAtPoint(tile, x: x, y: y)
                }
            }
        }
        
        if connectedView != nil {
            let viewport = connectedView!.getViewport()
            
            let tSize = CGFloat(tileSize)
            let size = CGSize(width: viewport.width * tSize, height: viewport.height * tSize)
            let point = CGPointMake(viewport.origin.x * tSize, frame.height - (viewport.origin.y * tSize))
            var viewRect = NSRect(origin: point, size: size)
            viewRect.offset(dx: -(viewport.width / 2) * tSize, dy: -(viewport.width / 2) * tSize)
            NSColor.whiteColor().setStroke()
            NSBezierPath.strokeRect(viewRect)
        }
    }
    
    private func moveViewTo(point: NSPoint) {
        if connectedView == nil {
            return
        }
        
        let normalized = normalizeMapPoint(point, viewport: connectedView.getViewport().size)
        engine.setCurrentMapPoint(normalized)
        connectedView.needsDisplay = true
        needsDisplay = true
    }
    
    private func drawTileAtPoint(tile: UInt16, x: Int, y: Int) {
        let imageInfo = tileImages.getTileImageInfo(Int(tile), acycle: 0)
        let image = tileImages.getImage(imageInfo.imageNumber)
        let position = CGPoint(x: x * tileSize, y: y * tileSize)
        image.drawAtPoint(position, fromRect: NSRect.zeroRect, operation: .CompositeSourceOver, fraction: 1.0)
    }
    
    private func normalizeMapPoint(var point: CGPoint, viewport: NSSize = NSSize.zeroSize) -> CGPoint {
        let halfViewportWidth = Int(viewport.width) >> 1   // Ints round down
        let halfViewportHeight = Int(viewport.height) >> 1 // Ints round down
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
