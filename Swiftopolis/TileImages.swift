//
//  TileImages.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/15/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa
import SpriteKit

private let GlobalTileImages = TileImages()

class TileImages {
    private(set) var spriteByName: [String : SKSpriteNode] = [:]
    private(set) var spriteImages: [SpriteKind : [Int : NSImage]] = [:]
    private(set) var tileImages: [TileImage!] = []
    private(set) var images: [NSImage] = []
    
    class var instance: TileImages {
        let this = GlobalTileImages
        this.initTileImages()
        return this
    }
    
    init() {
        initTileImageMap()
    }
    
    private func initTileImageMap() {
        if tileImages.count != 0 {
            return
        }
        
        let path = NSBundle.mainBundle().pathForResource("tiles_index", ofType: "json")
        let data = NSFileManager.defaultManager().contentsAtPath(path!)
        let json = JSON(data: data!)
        let length = json.arrayValue.count
        Utils.initializeArray(&self.tileImages, size: length, value: nil)
        for (_, subJson: JSON) in json {
            let tileName = subJson["name"].string
            var tileImage: TileImage? = nil
            if let offset = subJson["image"]["offsetY"].string {
                tileImage = SimpleTileImage()
                (tileImage! as SimpleTileImage).imageNumber = offset.toInt()!
            } else if let animation = subJson["animation"].array {
                var frames: [SimpleTileImage] = []
                for frame in animation {
                    if let offset = frame["offsetY"].string {
                        let img = SimpleTileImage()
                        img.imageNumber = offset.toInt()!
                        frames.append(img)
                    }
                }
                
                let animatedTile = AnimatedTile()
                animatedTile.frames = frames
                tileImage = animatedTile
            }
            
            if tileName != nil && tileImage != nil {
                tileImages.insert(tileImage!, atIndex: tileName!.toInt()!)
            }
        }
    }
    
    private func initTileImages() {
        if self.images.count != 0 {
            return
        }
        
        // TODO use dynamic name and dynamic dimensions
        self.images = loadTileImages("final.png", 16)
    }
    
    private func loadTileImages(imageName: String, _ size: Int) -> [NSImage] {
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
            
            let offsetY = Int(refImage!.size.height) - ((i + 1) * 16)
            let destinationRect = NSRect(x: 0, y: 0, width: size, height: size)
            let sourceRect = NSRect(x: 0, y: offsetY, width: size, height: size)
            refImage!.drawInRect(destinationRect, fromRect: sourceRect, operation: .CompositeSourceOver, fraction: 1.0, respectFlipped: true, hints: nil)
            
            img.unlockFocus()
            images[i] = img
        }
        
        return images.map({$0!})
    }
    
    class ImageInfo {
        var imageNumber: Int = 0
        var animated: Bool = false
    }
    
    func getTileImageInfo(tileNumber: Int, acycle: Int) -> ImageInfo {
        let tileImage = tileImages[tileNumber]
        let info = ImageInfo()
        if let ti = tileImage as? SimpleTileImage {
            info.imageNumber = ti.imageNumber
            info.animated = false
        } else if let ti = tileImage as? AnimatedTile {
            info.imageNumber = ti.getFrameByTime(acycle).imageNumber
            info.animated = false
        } else {
            fatalError("busted")
        }
        
        return info
    }
    
    func getImage(imageNumber: Int) -> NSImage {
        return self.images[imageNumber]
    }
}

protocol TileImage {}

class SimpleTileImage: TileImage {
    var imageNumber: Int = 0
}

class AnimatedTile: TileImage {
    var frames: [SimpleTileImage] = []
    
    func getFrameByTime(acycle: Int) -> SimpleTileImage {
        return frames[acycle % frames.count]
    }
}


