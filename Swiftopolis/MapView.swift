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

private let INVERT_Y_AXIS = false

class MapView : SKView {
    private var tileImages = TileImages.instance
    var currentPoint: CGPoint?
    private var currentRect: CGRect = CGRect.zeroRect
    private let VIEWPORT_WIDTH = 25
    private let VIEWPORT_HEIGHT = 25
    
    private var trackingArea: NSTrackingArea?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer = self.makeBackingLayer()
        self.layer?.delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        println("mouse entered")
        NSCursor.hide()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        NSCursor.unhide()
    }
    
    func onToolChanged(newTool: Tool) {
        if let s =  self.scene as? GameScene {
            s.setCurrentTool(newTool)
        }
    }
    
    override func updateTrackingAreas() {
        if self.trackingArea != nil {
            self.removeTrackingArea(self.trackingArea!)
        }
        
        let opts = NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.ActiveInActiveApp
        let trackingArea = NSTrackingArea(rect: self.bounds, options: opts, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
        self.trackingArea = trackingArea
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if self.currentPoint == nil {
            self.currentPoint = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        }
        
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
            
            println("\(xMin) \(yMin) -- \(xMin) \(yMax)")
            
//            for var y = 0, cameraY = yMax - 1; cameraY >= yMin; y++, cameraY-- { // inverted Y axis
            for var y = 0, cameraY = yMin; cameraY < yMax; y++, cameraY++ {
                for var x = 0, cameraX = xMin; cameraX < xMax; x++, cameraX++ {
                    let mapX = cameraX + (city.map.width / 2)
//                    let mapY = cameraY + (city.map.height / 2) // Inverted Y axis
                    let mapY = city.map.height - (cameraY + (city.map.height / 2)) - 1
                    if let tile = city.map.getTile(x: mapX, y: mapY) {
                        let imageInfo = self.tileImages.getTileImageInfo(Int(tile), acycle: 0)
                        let image = self.tileImages.getImage(imageInfo.imageNumber)
                        let position = CGPoint(x: x * 16, y: y * 16)
                        image.drawAtPoint(position, fromRect: NSRect.zeroRect, operation: .CompositeSourceOver, fraction: 1.0)
                    } else {
                        println("tile not found. \(mapX, mapY)")
                    }
                }
            }
            
            CGContextFlush(context)
        }
    }
}