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
                let tile = city.getTile(x: x, y: y)
//                switch mapState {
//                default:
//                }
            }
        }
    }
}