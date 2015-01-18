//
//  TileImage.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/17/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import AppKit

protocol TileImage {
    init()
    func getFrameEndTime(frameTime: Int) -> Int
//    func drawInRect(inout rect: NSRect)
    func drawInRect(inout rect: NSRect, offsetX: Int?, offsetY: Int?)
}

class TileImageLayer: TileImage {
    var below: TileImageLayer?
    var above: TileImage?
    
    required init() {}
    
    func getFrameEndTime(frameTime: Int) -> Int {
        if self.below == nil {
            return above!.getFrameEndTime(frameTime)
        }
        
        let belowEnd = below!.getFrameEndTime(frameTime)
        let aboveEnd = above!.getFrameEndTime(frameTime)
        
        if belowEnd < 0 {
            return aboveEnd;
        } else if aboveEnd < 0 || belowEnd < aboveEnd {
            return belowEnd
        } else {
            return aboveEnd
        }
    }
    
    func drawInRect(inout rect: NSRect, offsetX: Int? = nil, offsetY: Int? = nil) {
        if let b = self.below {
            b.drawInRect(&rect)
        }
        
        above!.drawInRect(&rect, offsetX: nil, offsetY: nil)
    }
}

class TileImageSprite : TileImage {
    var source: TileImage?
    var offsetX: Int = 0
    var offsetY: Int = 0
    
    required init() {}
    
    convenience init(source: TileImage) {
        self.init()
        self.source = source
    }
    
    func getFrameEndTime(frameTime: Int) -> Int {
        return source!.getFrameEndTime(frameTime)
    }
    
    func drawInRect(inout rect: NSRect, offsetX: Int? = nil, offsetY: Int? = nil) {
        source?.drawInRect(&rect, offsetX: self.offsetX, offsetY: self.offsetY)
    }
}

class SourceImage: TileImage {
    var image: NSImage!
    var basisSize: Int = 0
    var targetSize: Int = 0
    
    required init() {}
    
    convenience init(image: NSImage, basisSize: Int, targetSize: Int) {
        self.init()
        self.image = image
        self.basisSize = basisSize
        self.targetSize = targetSize
    }
    
    func getFrameEndTime(frameTime: Int) -> Int {
        return -1
    }
    
    func drawInRect(inout rect: NSRect, offsetX: Int? = nil, offsetY: Int? = nil) {
        var x = offsetX, y = offsetY
        if x == nil {
            x = 0
        }
        
        if y == nil {
            y = 0
        }
        
        let offX = CGFloat(x!)
        let offY = image.size.height - (CGFloat(y!)) - 16
        
        println(rect.origin)
        
        image.drawAtPoint(rect.origin, fromRect: NSRect(x: offX, y: offY, width: 16, height: 16), operation: .CompositeSourceOver, fraction: 1.0)
        rect.origin.y -= 16.0
    }
}