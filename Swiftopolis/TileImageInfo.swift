//
//  TileImageInfo.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 3/12/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

private var GlobalTileImageInfo: TileImageInfo! = nil
private let tileInfoInitQueue = dispatch_queue_create("com.chrisbenincasa.swiftopolis.tile_info_queue", DISPATCH_QUEUE_SERIAL)

class TileImageInfo {
    private(set) var tileImages: [TileImage?] = []
    
    class func vend() -> TileImageInfo {
        var ret: TileImageInfo!
        dispatch_sync(tileInfoInitQueue) {
            if let tex = GlobalTileImageInfo {
                ret = tex
            } else {
                GlobalTileImageInfo = TileImageInfo()
                ret = GlobalTileImageInfo
            }
        }
        return ret
    }
    
    init() {
        tileImages = initTileImageMap()
    }
    
    func getTileImageInfo(tileNumber: UInt16, acycle: Int) -> (Int, Bool) {
        return getTileImageInfo(Int(tileNumber), acycle: acycle)
    }
    
    func getTileImageInfo(tileNumber: Int, acycle: Int) -> (Int, Bool) {
        let tileImage = tileImages[tileNumber]
        var imageNumber = 0
        var isAnimated = false
        if let ti = tileImage as? SimpleTileImage {
            imageNumber = ti.imageNumber
        } else if let ti = tileImage as? AnimatedTile {
            imageNumber = ti.getFrameByTime(acycle).imageNumber
            isAnimated = true
        } else {
            fatalError("busted")
        }
        
        return (imageNumber, isAnimated)
    }
    
    private func initTileImageMap() -> [TileImage?] {
        var tileImages: [TileImage?] = []
        Utils.initializeArray(&tileImages, size: 1000, value: nil)
        let path = NSBundle.mainBundle().pathForResource("tiles_index", ofType: "json")
        let data = NSFileManager.defaultManager().contentsAtPath(path!)
        let json = JSON(data: data!)
        
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
            
            tileImages[tileName!.toInt()!] = tileImage
        }
        
        return tileImages
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
