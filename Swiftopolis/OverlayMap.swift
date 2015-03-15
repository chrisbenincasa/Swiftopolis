//
//  OverlayMap.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 3/11/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import SpriteKit

func debounce(delay: NSTimeInterval, action: () -> ()) -> (() -> ()) {
    var lastFireTime: dispatch_time_t = 0
    let dispatchDelay = UInt64(delay * Double(NSEC_PER_SEC))
    
    println("-- initiliazing debounced function --")
    
    return {
        let now = dispatch_time(DISPATCH_TIME_NOW, 0)
        
        if now - lastFireTime >= dispatchDelay {
            action()
        }
        
        lastFireTime = now
    }
}

class OverlayMap: SKNode, Subscriber {
    var connectedMap: CityWorld!
    
    private let TILE_SIZE = 3
    private var tileImages: TileImages!
    private var engine: Engine
    private var mapState: MapState = .All
    private var map: SKSpriteNode = SKSpriteNode()
    private var viewportNode: SKShapeNode!
    private var dirtyCoords: [(Int, Int)] = []
    private var currentMapImage: NSImage
    private let barrier = dispatch_queue_create("com.chrisbenincasa.micropolis.overlay", DISPATCH_QUEUE_SERIAL)
    
    private var dragInProgress = false
    
    required init(engine _engine: Engine, connectedMap _connectedMap: CityWorld) {
        engine = _engine
        connectedMap = _connectedMap
        currentMapImage = NSImage(size: NSSize(width: self.engine.city.map.width, height: self.engine.city.map.height) * self.TILE_SIZE)
        
        super.init()
        
        engine.city.addSubscriber(self)
        
        tileImages = TileImages.vend(3) {
            println("-- preloaded 3px tile textures --")
        }
        userInteractionEnabled = true
        
        viewportNode = SKShapeNode(rect: CGRect(origin: CGPoint.zeroPoint, size: connectedMap.viewportSize * TILE_SIZE))
        viewportNode.lineWidth = 2
        viewportNode.strokeColor = NSColor.whiteColor()
        viewportNode.zPosition = 1
        viewportNode.position = CGPoint(x: engine.city.map.width / 2 * TILE_SIZE - Int(viewportNode.frame.width) / 2, y: engine.city.map.height / 2 * TILE_SIZE - Int(viewportNode.frame.height) / 2)
        addChild(viewportNode)
        
        map.position = CGPoint.zeroPoint
        map.size = CGSize(width: engine.city.map.width, height: engine.city.map.height) * TILE_SIZE
        map.anchorPoint = CGPoint.zeroPoint
        addChild(map)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(theEvent: NSEvent) {
        handleMouseEvent(theEvent)
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        dragInProgress = true
        handleMouseEvent(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        dragInProgress = false
    }
    
    private func handleMouseEvent(theEvent: NSEvent) {
        let localPoint = theEvent.locationInNode(map) / TILE_SIZE
        let mapPoint = CGPoint(x: Int(localPoint.x), y: engine.city.map.height - Int(localPoint.y))
        moveViewTo(mapPoint)
    }
    
    func draw() {
        println("-- redrawing overlay map --")
        
        // Draw the new overlay map image asynchronously and update the texture
        // The updated texture will get picked up on the next render cycle by SpriteKit
        // We do this so the drawing of the overlay image doesn't block the main queue
        dispatch_async(self.barrier) {
            self.currentMapImage.lockFocus()
            
            for var y = 0; y < self.engine.city.map.height; y++ {
                for var x = 0; x < self.engine.city.map.width; x++ {
                    // Map coordinate-system has (0, 0) in the top-left while NSRect coordinate
                    // system has (0, 0) in the bottom-left
                    let mapY = self.engine.city.map.height - (y + 1)
                    var tile = self.engine.city.getTile(x: x, y: mapY)
                    switch self.mapState {
                    case .Residential:
                        if TileConstants.isZone(tile) && !TileConstants.isResidentialZoneAny(tile) {
                            tile = TileConstants.DIRT
                        }
                        break
                    case .Commercial:
                        if TileConstants.isZone(tile) && !TileConstants.isCommercialZone(tile) {
                            tile = TileConstants.DIRT
                        }
                        break
                    case .Industrial:
                        if TileConstants.isZone(tile) && !TileConstants.isIndustrialZone(tile) {
                            tile = TileConstants.DIRT
                        }
                        break
                    default: break
                    }
                    
                    let (imageNumber, _) = self.tileImages.tileImageInfo.getTileImageInfo(tile, acycle: self.engine.city.getAnimationCycle())
                    let image = self.tileImages.getImage(imageNumber)
                    let position = CGPoint(x: x, y: y) * self.TILE_SIZE
                    image.drawAtPoint(position, fromRect: NSRect.zeroRect, operation: .CompositeSourceOver, fraction: 1.0)
                }
            }
            
            self.currentMapImage.unlockFocus()
            
            self.map.texture = SKTexture(image: self.currentMapImage)
        }
    }
    
    private func moveViewTo(point: NSPoint) {
        let connectedViewport = connectedMap.viewportSize
        let citySize = CGSize(width: engine.city.map.width, height: engine.city.map.height)
        let normalized = PointUtils.normalizeMapPoint(point, bounds: citySize, viewport: connectedViewport)
        engine.setCurrentMapPoint(normalized)
        let newPoint = CGPoint(x: normalized.x, y: CGFloat(engine.city.map.height) - normalized.y) - (connectedViewport.width / 2, connectedViewport.height / 2)
        viewportNode.position = newPoint * TILE_SIZE
    }
    
    private lazy var debouncedDraw: () -> () = debounce(1.0, self.draw)
    
    func tileChanged(x: Int, y: Int) {
        debouncedDraw()
    }
}