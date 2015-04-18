//
//  TileReader.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/17/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import AppKit

class TileReader {
    var json: JSON
    var mappings: [TileMapping] = []
    var tileSize: Int = 16
    
    init(_json: JSON, _size: Int) {
        json = _json
        tileSize = _size
    }
    
    func process() -> NSData? {
        var nextOffsetY = 0
        var mappings: [TileMapping] = []
        
        for (_, subJson: JSON) in self.json {
            let rawDict = subJson.dictionaryObject
            if let images = rawDict?["images"] as? [String] {
                // Load layers or frames
                if let image = parseFrameSpec(images, frames: rawDict?["frames"] as? [String]) {
                    var dest: TileImage? = nil
                    if image.getFrameEndTime(0) > 0 {
                        var animation = Animation()
                        var t = 0, n = image.getFrameEndTime(t)
                        
                        while n > 0 {
                            var sprite = TileImageSprite()
                            sprite.offsetY = nextOffsetY
                            nextOffsetY += tileSize
                            animation.frames.append(Animation.Frame(frame: sprite, duration: n - t))
                            t = n
                            n = image.getFrameEndTime(t)
                        }
                        
                        dest = animation
                    } else {
                        let imageSprite = TileImageSprite()
                        imageSprite.offsetY = nextOffsetY
                        nextOffsetY += tileSize
                        dest = imageSprite
                    }
                    
                    let mapping = TileMapping(name: subJson["name"].string!, ref: image, dest: dest!)
                    mappings.append(mapping)
                }
            }
        }
        
        // Create composite image
        let imageSize = NSSize(width: tileSize, height: nextOffsetY)
        var imageRect = NSRect(origin: NSPoint(x: 0, y: nextOffsetY - tileSize), size: imageSize)
        let composite = NSImage(size: imageSize)
        composite.lockFocusFlipped(false)
        
        NSGraphicsContext.currentContext()?.imageInterpolation = .None // dat pixel effect
        
        for mapping in mappings {
            if let a = mapping.dest as? Animation {
                var t = 0
                // TODO make me functional.
//                let x = a.frames.flatMap({ (i: Animation.Frame) -> [TileImageSprite] in
//                    return (i.image as? TileImageSprite).toArray()
//                }).map({ (sprite: TileImageSprite) -> NSRect in
//                    return NSRect.zeroRect
//                }).reduce(NSRect.zeroRect, combine: { (accum, var next) -> NSRect in
//                    let offset = NSOffsetRect(next, 0, accum.height)
//                    return NSUnionRect(accum, next)
//                })
                
                for frame in a.frames {
                    if let s = frame.image as? TileImageSprite {
                        mapping.ref.drawInRect(&imageRect, offsetX: nil, offsetY: nil, time: t)
                        imageRect.origin.y -= CGFloat(tileSize)
                    }
                    
                    t += frame.duration
                }
            } else if let d = mapping.dest as? TileImageSprite {
                mapping.ref.drawInRect(&imageRect, offsetX: nil, offsetY: nil, time: nil)
                imageRect.origin.y -= CGFloat(tileSize)
            }
        }
        
//        for i in 0..<4 {
//            mappings[i].ref.drawInRect(&imageRect, offsetX: nil, offsetY: nil, time: nil)
//        }
        
        self.mappings = mappings
        
        // Create bitmap representation, convert to PNG data, delete old file and save
        
        let rep: NSBitmapImageRep = NSBitmapImageRep(focusedViewRect: NSRect(x: 0, y: 0, width: tileSize, height: nextOffsetY))!
        
        composite.unlockFocus()
        
        return rep.representationUsingType(.NSPNGFileType, properties: [:])
    }
    
    func generateIndexFile() -> JSON {
        if mappings.count == 0 {
            println("no mappings to generate indexes for!")
        }
        
        var json: JSON = []
        
        for mapping in mappings {
            var jsonMapping: [String:AnyObject] = ["name":mapping.tileName]
            
            if let animation = mapping.dest as? Animation {
                let frames = animation.frames.map({ (frame: Animation.Frame) -> [String : String] in
                    let sprite = frame.image as! TileImageSprite
                    return ["offsetY" : String(sprite.offsetY / self.tileSize)]
                })
                jsonMapping["animation"] = frames
            } else {
                let sprite = mapping.dest as! TileImageSprite
                jsonMapping["image"] = ["offsetY" : String(sprite.offsetY / tileSize)]
            }
            
            json.arrayObject?.append(jsonMapping)
        }
        
        return json
    }
    
    func generateTileNames() -> [String] {
        var names = [String]()
        for (_, subJson: JSON) in self.json {
            names.append(subJson["name"].string!)
        }
        
        return names
    }
    
    private func parseFrameSpec(layers: [String], frames: [String]?) -> TileImage? {
        if let f = frames {
            return loadAnimation(f)
        } else {
            if layers.count == 1 {
                return parseIndividualLayer(layers[0])
            }
            
            var result: TileImageLayer? = nil
            for layer in layers {
                var l = TileImageLayer()
                l.below = result
                l.above = parseIndividualLayer(layer)
                result = l
            }
            
            return result
        }
    }
    
    private func parseIndividualLayer(layer: String) -> TileImage? {
        let parts = [String](layer.componentsSeparatedByString("@"))
        let image = loadImage(parts[0])
        
        if image == nil {
            return nil
        }
        
        if parts.count >= 2 {
            let offset = parts[1].componentsSeparatedByString(",")
            var sprite = TileImageSprite(source: image!)
            
            if offset.count >= 1 {
                sprite.offsetX = offset[0].toInt()!
            }
            
            if offset.count >= 2 {
                sprite.offsetY = offset[1].toInt()!
            }
            
            return sprite
        }
        
        return image
    }
    
    private func loadAnimation(frames: [String]) -> TileImage? {
        var animation: Animation? = nil
        if frames.count > 0 {
            animation = Animation()
            let fs = frames.map(parseIndividualLayer).filter({ $0 != nil }).map({ $0! }).map({ (image: TileImage) -> Animation.Frame in
                return Animation.Frame(frame: image, duration: AnimationConstants.DEFAULT_DURATION)
            })
            
            animation!.frames = fs
        }
        
        return animation
    }
    
    private func loadImage(fileName: String) -> TileImage? {
        let wd = NSFileManager.defaultManager().currentDirectoryPath
        let sizedFileName: String = "\(wd)/\(fileName)_\(self.tileSize)x\(self.tileSize).png"
        let regularFileName: String = "\(wd)/\(fileName).png"
        
        var data: NSData?
        var baseSize: Int = 16
        
        if let d = NSData(contentsOfFile: sizedFileName) {
            data = d
            baseSize = tileSize
        } else if let d = NSData(contentsOfFile: regularFileName) {
            data = d
        } else {
            println("could not find file: \(sizedFileName) or \(regularFileName)")
        }
        
        if let imageData = data {
            let img = NSImage(dataIgnoringOrientation: imageData)
            img!.setName(fileName)
            return SourceImage(image: img!, basisSize: baseSize, targetSize: tileSize)
        }

        return nil
    }
}