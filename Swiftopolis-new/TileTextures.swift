//
//  TileTextures.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 3/12/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import SpriteKit

private var GlobalTileTextures: [Int : TileTextures] = [:]
private let initQueue = dispatch_queue_create("com.chrisbenincasa.swiftopolis.tile_texture_queue", DISPATCH_QUEUE_SERIAL)

class TileTextureFactory {
    class func vend(size: Int, cb: () -> Void = { _ in }) -> TileTextures {
        var ret: TileTextures!
        dispatch_sync(initQueue) {
            if let tex = GlobalTileTextures[size] {
                ret = tex
            } else {
                ret = TileTextures(name: "\(size)x\(size)", size: size)
                GlobalTileTextures[size] = ret
                ret.preloadTextures(cb)
            }
        }
        return ret
    }
}

class TileTextures {
    private(set) var tileImageInfo: TileImageInfo
    private var tileImages: [TileImage?] {
        return tileImageInfo.tileImages
    }
    private(set) var name: String
    private(set) var size: Int
    private(set) var atlas: SKTextureAtlas!
    private(set) var textures: [SKTexture?] = []
    
    init(name _name: String, size _size: Int) {
        name = _name
        size = _size
        tileImageInfo = TileImageInfo.vend()
        
        Utils.initializeArray(&textures, size: tileImages.count, value: nil)
        let images = TileImages.loadTileImages("final-\(name).png", size)
        
        var atlasDict: [String: AnyObject] = [:]
        for i in 0..<images.count {
            let key = String(i)
            let value = images[i]
            atlasDict[key] = value
        }
        
        atlas = SKTextureAtlas(dictionary: atlasDict)
    }
    
    func preloadTextures(cb: () -> Void = { _ in }) {
        atlas.preloadWithCompletionHandler {
            for name in self.atlas.textureNames {
                if let nameAsInt = Int(name) {
                    self.textures[nameAsInt] = self.atlas.textureNamed(name)
                }
            }
            
            cb()
        }
    }
}