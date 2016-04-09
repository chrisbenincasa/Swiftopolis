//
//  CachedTextureAtlas.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 3/14/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import SpriteKit

private var CachedInstancesByAtlasName: [String : CachedTextureAtlas] = [:]

// Serial queue to ensure that two simulatenous calls to initialize the same
// cached texture atlas doesn't needlessly instantiate multiple objects
private let initQueue = dispatch_queue_create("com.chrisbenincasa.swiftopolis.cached_texture_atlas_init", DISPATCH_QUEUE_SERIAL)

class CachedTextureAtlas {
    private var name: String
    private var atlas: SKTextureAtlas
    private(set) var cachedTextures: [String : SKTexture] = [:]
    private(set) var loaded = false
    
    class func vend(resourceName: String, callback: () -> () = noop) -> CachedTextureAtlas {
        var cachedAtlas: CachedTextureAtlas!
        
        dispatch_sync(initQueue) {
            if let instance = CachedInstancesByAtlasName[resourceName] {
                cachedAtlas = instance
                callback()
            } else {
                cachedAtlas = CachedTextureAtlas(name: resourceName)
                cachedAtlas.preloadCachedTextures(callback)
                CachedInstancesByAtlasName[resourceName] = cachedAtlas
            }
        }
        
        return cachedAtlas
    }
    
    init(name _name: String) {
        name = _name
        atlas = SKTextureAtlas(named: name)
    }
    
    private func preloadCachedTextures(callback: () -> ()) {
        atlas.preloadWithCompletionHandler {
            for name in self.atlas.textureNames {
                self.cachedTextures[name] = self.atlas.textureNamed(name)
            }
            
            self.loaded = true
            callback()
        }
    }
}