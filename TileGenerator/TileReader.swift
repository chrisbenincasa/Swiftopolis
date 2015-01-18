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
    
    init(_json: JSON) {
        json = _json
    }
    
    func process() {
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
                            nextOffsetY += 16
                            animation.frames.append(Animation.Frame(frame: sprite, duration: n - t))
                            t = n
                            n = image.getFrameEndTime(t)
                        }
                        
                        dest = animation
                    } else {
                        let imageSprite = TileImageSprite()
                        imageSprite.offsetY = nextOffsetY
                        nextOffsetY += 16
                        dest = imageSprite
                    }
                    
                    let mapping = TileMapping(name: subJson["name"].string!, ref: image, dest: dest!)
                    mappings.append(mapping)
                }
            }
        }
        
        // Create composite image
        let imageSize = NSSize(width: 16, height: nextOffsetY)
        var imageRect = NSRect(origin: NSPoint(x: 0, y: nextOffsetY - 16), size: imageSize)
        let composite = NSImage(size: imageSize)
        composite.lockFocusFlipped(false)
        
        NSGraphicsContext.currentContext()?.imageInterpolation = .None // dat pixel effect
        
        for mapping in mappings {
            if let a = mapping.dest as? Animation {
                
            } else if let d = mapping.dest as? TileImageSprite {
                mapping.ref.drawInRect(&imageRect, offsetX: nil, offsetY: nil, time: nil)
            }
        }
        
        // Create bitmap representation, convert to PNG data, delete old file and save
        println(composite.representations.count)
        
        let rep: NSBitmapImageRep = NSBitmapImageRep(focusedViewRect: NSRect(x: 0, y: 0, width: 16, height: nextOffsetY))!
        let data = rep.representationUsingType(.NSPNGFileType, properties: [:])
        NSFileManager.defaultManager().removeItemAtPath(NSFileManager.defaultManager().currentDirectoryPath + "/" + "final.png", error: nil)
        data?.writeToFile(NSFileManager.defaultManager().currentDirectoryPath + "/" + "final.png", atomically: false)
        
        composite.unlockFocus()
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
        if let data = NSData(contentsOfFile: wd + "/" + fileName + ".png") {
            let img = NSImage(dataIgnoringOrientation: data)
            img!.setName(fileName)
            return SourceImage(image: img!, basisSize: 16, targetSize: 16)
        } else {
            println("could not find file: " + wd + "/" + fileName + ".png")
        }

        return nil
    }
}