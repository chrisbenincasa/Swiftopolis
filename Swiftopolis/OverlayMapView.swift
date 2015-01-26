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
                    let imageInfo = self.tileImages.getTileImageInfo(Int(tile), acycle: 0)
                    let image = self.tileImages.getImage(imageInfo.imageNumber)
                    let position = CGPoint(x: x * tileSize, y: y * tileSize)
                    image.drawAtPoint(position, fromRect: NSRect.zeroRect, operation: .CompositeSourceOver, fraction: 1.0)
                }
            }
        }
        
        CGContextFlush(context)
    }
}