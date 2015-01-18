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
                if let image = parseFrameSpec(images) {
                    var dest: TileImage? = nil
                    if image.getFrameEndTime(0) > 0 {
                        
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
        
        println("image has size \(imageSize)")
        
        NSGraphicsContext.currentContext()?.imageInterpolation = .None // dat pixel effect
        
        for mapping in mappings {
            if let d = mapping.dest as? TileImageSprite {
                mapping.ref.drawInRect(&imageRect, offsetX: nil, offsetY: nil)
            }
        }
        
        // Create bitmap representation, convert to PNG data, delete old file and save
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
    
    private func parseFrameSpec(layers: [String]) -> TileImage? {
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
        
        return nil
    }
    
    private func parseIndividualLayer(layer: String) -> TileImage? {
        let parts = [String](layer.componentsSeparatedByString("@"))
        let image = loadImageOrAnimation(parts[0])
        
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
    
    private func loadImageOrAnimation(fileName: String) -> TileImage? {
        let wd = NSFileManager.defaultManager().currentDirectoryPath
        if NSFileManager.defaultManager().fileExistsAtPath(wd + "/" + fileName + ".ani") {
            return loadAnimation(fileName)
        } else {
            return loadImage(fileName)
        }
    }
    
    private func loadAnimation(fileName: String) -> TileImage? {
        return nil
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