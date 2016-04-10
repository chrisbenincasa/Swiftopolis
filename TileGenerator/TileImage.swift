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
    func drawInRect(inout rect: NSRect, offsetX: Int?, offsetY: Int?, time: Int?)
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
    
    func drawInRect(inout rect: NSRect, offsetX: Int? = nil, offsetY: Int? = nil, time: Int? = nil) {
        if let b = self.below {
            b.drawInRect(&rect)
        }
        
        above!.drawInRect(&rect, offsetX: nil, offsetY: nil, time: nil)
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
    
    func drawInRect(inout rect: NSRect, offsetX: Int? = nil, offsetY: Int? = nil, time: Int? = nil) {
        source?.drawInRect(&rect, offsetX: self.offsetX, offsetY: self.offsetY, time: nil)
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
    
    func drawInRect(inout rect: NSRect, offsetX: Int? = nil, offsetY: Int? = nil, time: Int? = nil) {
        var x = offsetX, y = offsetY
        if x == nil {
            x = 0
        }
        
        if y == nil {
            y = 0
        }
        
        let offX = (x! * basisSize / 16)
        let offY = Int(image.size.height) - (y! * basisSize / 16) - basisSize
        let basisRect = NSRect(origin: CGPoint(x: offX, y: offY), size: CGSize(width: basisSize, height: basisSize))
        
        if targetSize == basisSize {
            image.drawAtPoint(rect.origin, fromRect: basisRect, operation: .CompositeSourceOver, fraction: 1.0)
        } else {
            let scaled = scaleImage(basisRect)
            scaled.drawAtPoint(rect.origin, fromRect: NSRect.zero, operation: .CompositeSourceOver, fraction: 1.0)
        }
    }
    
    private func scaleImage(sourceRect: NSRect) -> NSImage {
        let newImage = NSImage(size: NSSize(width: targetSize, height: targetSize))
        let newRect = NSRect(x: 0, y: 0, width: targetSize, height: targetSize)
        newImage.lockFocus()
        image.drawInRect(newRect, fromRect: sourceRect, operation: .CompositeSourceOver, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}

struct AnimationConstants {
    static let DEFAULT_DURATION = 125
}

class Animation: TileImage {
    var frames: [Frame] = []
    
    required init() {}
    
    func getFrameEndTime(frameTime: Int) -> Int {
        var t = 0
        for frame in self.frames {
            t += frame.duration
            if frameTime < t {
                return t
            }
        }
        
        return -1
    }
    
    func drawInRect(inout rect: NSRect, offsetX: Int?, offsetY: Int?, time: Int?) {
        var t = 0
        for frame in self.frames {
            let d = t + frame.duration
            if (time != nil) && time! < d {
                frame.image.drawInRect(&rect, offsetX: offsetX, offsetY: offsetY, time: nil)
                return
            }
            
            t = d
        }
    }
    
    class Frame {
        var image: TileImage
        var duration: Int
        
        init(frame: TileImage, duration: Int) {
            self.image = frame
            self.duration = duration
        }
    }
}