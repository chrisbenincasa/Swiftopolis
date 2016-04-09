//
//  TileImages.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/15/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa
import SpriteKit

private var GlobalTileImages: [Int : TileImages] = [:]
private let initQueue = dispatch_queue_create("com.chrisbenincasa.swiftopolis.tile_image_init", DISPATCH_QUEUE_SERIAL)

/// Container for tile images
/// Keeps an array of NSImages which are indexed on tile number
class TileImages {
    private(set) var name: String
    private(set) var size: Int
    private(set) var images: [NSImage] = []
    private(set) var tileImageInfo: TileImageInfo
    private var tileImages: [TileImage?] {
        return tileImageInfo.tileImages
    }
    
    class func vend(size: Int, cb: () -> () = noop) -> TileImages {
        var ret: TileImages!
        dispatch_sync(initQueue) {
            if let img = GlobalTileImages[size] {
                ret = img
            } else {
                ret = TileImages(name: "\(size)x\(size)", size: size)
                GlobalTileImages[size] = ret
            }
            
            cb()
        }
        
        return ret
    }
    
    class func loadTileImages(imageName: String, _ size: Int) -> [NSImage] {
        let refImage = NSBundle.mainBundle().imageForResource(imageName)
        
        if refImage == nil {
            fatalError("NO REFERENCE IMAGE NOO")
        }
        
        var images: [NSImage!] = []
        Utils.initializeArray(&images, size: Int(refImage!.size.height) / size, value: nil)
        for i in 0..<Int(refImage!.size.height) / size {
            let img = NSImage(size: NSSize(width: size, height: size))
            img.lockFocusFlipped(false)
            NSGraphicsContext.currentContext()?.imageInterpolation = .None // dat pixel effect
            
            let offsetY = Int(refImage!.size.height) - ((i + 1) * size)
            let destinationRect = NSRect(x: 0, y: 0, width: size, height: size)
            let sourceRect = NSRect(x: 0, y: offsetY, width: size, height: size)
            refImage!.drawInRect(destinationRect, fromRect: sourceRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true, hints: nil)
            
            img.unlockFocus()
            images[i] = img
        }
        
        return images.map({$0!})
    }
    
    init(name _name: String, size _size: Int) {
        name = _name
        size = _size
        tileImageInfo = TileImageInfo.vend()
        images = TileImages.loadTileImages("final-\(self.name).png", self.size)
    }
    
    func getImage(imageNumber: Int) -> NSImage {
        return self.images[imageNumber]
    }
}
