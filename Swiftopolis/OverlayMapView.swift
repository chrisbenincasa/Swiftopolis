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
    
    var city: City!
    var connectedView: MapView!
    private let tileSize = 3
    private var tileImages: TileImages!
    private var mapState: MapState = .All
    
    init(city: City, frame: NSRect) {
        super.init(frame: frame)
        self.city = city
        self.tileImages = TileImages.instance(self.tileSize)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tileImages = TileImages.instance(self.tileSize)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let localPoint = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let mapPoint = CGPoint(x: Int(localPoint.x) / tileSize, y: city.map.height - Int(localPoint.y) / tileSize)
        println("map point = \(mapPoint)")
        moveViewTo(mapPoint)
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let localPoint = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let mapPoint = CGPoint(x: Int(localPoint.x) / tileSize, y: city.map.height - Int(localPoint.y) / tileSize)
        println("map point = \(mapPoint)")
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
//            let currentPoint 
        }
        
        CGContextFlush(context)
    }
    
    private func moveViewTo(point: NSPoint) {
        if connectedView == nil {
            println("connected view is nil")
            return
        }
        
        var newPoint = NSPoint(x: Int(point.x) - (city.map.width / 2), y: (city.map.height / 2) - Int(point.y))
//        if newPoint.x < 0 && Int(newPoint.x) < -(city.map.width >> 2) {
//            newPoint.x = -CGFloat(city.map.width >> 2)
//        } else if newPoint.x > 0 && Int(newPoint.x) > (city.map.width >> 2) {
//            newPoint.x = CGFloat(city.map.width >> 2)
//        }
//        
//        if newPoint.y < 0 && Int(newPoint.y) < -(city.map.height >> 2) {
//            newPoint.y = -CGFloat(city.map.height >> 2)
//        } else if newPoint.y > 0 && Int(newPoint.y) > (city.map.height >> 2) {
//            newPoint.y = CGFloat(city.map.height >> 2)
//        }
        
//        println(newPoint)
        connectedView.currentMapPoint = point
        connectedView.needsDisplay = true
    }
    
    private func drawTileAtPoint(tile: UInt16, x: Int, y: Int) {
        let imageInfo = self.tileImages.getTileImageInfo(Int(tile), acycle: 0)
        let image = self.tileImages.getImage(imageInfo.imageNumber)
        let position = CGPoint(x: x * tileSize, y: y * tileSize)
        image.drawAtPoint(position, fromRect: NSRect.zeroRect, operation: .CompositeSourceOver, fraction: 1.0)
    }
}
