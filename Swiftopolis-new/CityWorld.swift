//
//  CityWorld.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/14/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa
import SpriteKit

struct WorldConstants {
    static let TILE_WIDTH = 44
    static let TILE_HEIGHT = 44
    static let TILE_SIZE = 16
}

class CityWorld: SKNode, EngineEventListener, Subscriber {
    var viewportSize: CGSize {
        return CGSize(width: WorldConstants.TILE_WIDTH, height: WorldConstants.TILE_HEIGHT)
    }
    private var tileTextures: TileTextures!
    private var engine: Engine!
    
    // Tools
    private var toolCursor: ToolCursor!
    var currentTool: Tool! {
        didSet {
            setToolCursor()
        }
    }
    private var currentStroke: ToolStroke?
    private var toolNode: ToolNode?
    
    // Map
    private(set) var tiles: [[SKSpriteNode!]] = []
    private(set) var animatedTiles: [CityLocation] = []
    private(set) var unpoweredTiles: [CityLocation] = []
    
    private var blink = false
    private let blinkTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
    private var dragInProgress = false
    private var lastDragPoint: CityLocation?
    
    init(engine _engine: Engine) {
        super.init()
        engine = _engine
        engine.registerListener(self)
        engine.city.addSubscriber(self)
        
        userInteractionEnabled = true
        
        dispatch_source_set_timer(blinkTimer, DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC, 10)
        dispatch_source_set_event_handler(blinkTimer) { [unowned self] in self.doBlink() }
        dispatch_resume(blinkTimer)
        
        let viewport = viewportSize
        Utils.initializeMatrix(&tiles, width: Int(viewport.height), height: Int(viewport.width), value: nil)
        let topLeft = PointUtils.topLeftMapPoint(engine.currentMapPoint, viewport: viewportSize)
        let topYPosition = Int(viewportSize.height) - 1
        
        var i = topYPosition
        for (y, arrY) in Zip2Sequence(Int(topLeft.y)..<Int(topLeft.y + viewport.height), NaturalNumbers()) {
            for (x, arrX) in Zip2Sequence(Int(topLeft.x)..<Int(topLeft.x + viewport.width), NaturalNumbers()) {
                if engine.city.map.tileExists(x: x, y: y) {
                    let sprite = SKSpriteNode()
                    sprite.size = CGSize(width: WorldConstants.TILE_SIZE, height: WorldConstants.TILE_SIZE)
                    sprite.position = CGPoint(x: arrX, y: i) * WorldConstants.TILE_SIZE
                    sprite.anchorPoint = CGPoint.zero
                    tiles[arrY][arrX] = sprite
                    addChild(tiles[arrY][arrX])
                }
            }
            
            i -= 1
        }
        
        tileTextures = TileTextureFactory.vend(WorldConstants.TILE_SIZE) {
            print("-- preloaded 16px tile textures --")
            self.mapCenterChanged()
        }
        
        currentTool = .Residential
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseExited(theEvent: NSEvent) {
        if let tool = toolNode {
            tool.hidden = true
        }
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        if let tool = toolNode {
            tool.hidden = false
        }
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        if !self.containsPoint(theEvent.locationInWindow) {
            return
        }
        
        // TODO toss events that are out of the bounds of the scene
        if let tool = toolNode {
            let location = theEvent.locationInNode(self)
            var newPoint = getToolPoint(location)
            let height = viewportSize.height
            
            if newPoint.x < 0 ||
                newPoint.y < 0 ||
                (Int(newPoint.x) + currentTool.size() > WorldConstants.TILE_WIDTH) ||
                (Int(newPoint.y) + currentTool.size() > WorldConstants.TILE_HEIGHT) {
                return
            }
            
            if tool.position != (newPoint * WorldConstants.TILE_SIZE) {
                tool.position = (newPoint * WorldConstants.TILE_SIZE)
            }
            
            // Update y-position for tool cursor rect
            let topLeft = PointUtils.topLeftMapPoint(engine.currentMapPoint, viewport: viewportSize)
            newPoint.y = height - (newPoint.y - topLeft.y) - 1
            
            setToolCursor(NSRect(x: Int(newPoint.x), y: Int(newPoint.y), width: currentTool.size(), height: currentTool.size()))
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        
        let location = theEvent.locationInNode(self)
        
        // convert to map point
        let cityLocation = cityLocationFromClickPoint(location)
        let pressedButtons = NSEvent.pressedMouseButtons()
        
        switch pressedButtons {
        case 1: // left mouse
            if currentTool == nil {
                return
            }
            
            if currentTool == .Query {
                //
            } else {
                // Start the current stroke
                let currentPreview = engine.toolPreview
//                println("-- began ToolStroke at (\(cityLocation.x), \(cityLocation.y)) --")
                currentStroke = currentTool.beginStroke(engine.city, x: cityLocation.x, y: cityLocation.y)
                if let preview = previewTool() {
                    redrawToolPreview(currentStroke!, oldPreview: currentPreview, newPreview: preview)
                }
            }
            
            break
        case 2: break
        default: // any other button
            // This is still a little busted because we don't validate/normalize the point we set to the new camera
            // location, so you can keep clicking but the map won't move
            // The map validates/normalizes the requested point to draw around, but we set blindly
            // TODO: Factor out the validation methods so we can use them here before blindly setting the camera point
            print("clicked \(pressedButtons)")
            break
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        if currentTool == nil {
            return
        }
        
        dragInProgress = true
        
        let location = theEvent.locationInNode(self)
        let newLocation = cityLocationFromClickPoint(location)
        
        if lastDragPoint.isDefined() && lastDragPoint == newLocation {
            return
        }
        
        if let stroke = currentStroke {
            let currentPreview = engine.toolPreview
            
            stroke.dragTo(newLocation.x, newLocation.y)
            
//            println("-- ToolStroke dragged to (\(newLocation.x), \(newLocation.y)) --")
            
            if let preview = previewTool() {
                redrawToolPreview(stroke, oldPreview: currentPreview, newPreview: preview)
            }
            
            let newPoint = getToolPoint(location)
            let newViewPoint = newPoint * WorldConstants.TILE_SIZE
            
            setToolCursor(stroke.getBounds())
            
            // Update toolNode position if we're moving west -> east or north -> south
            lastDragPoint.foreach { point in
                if newLocation.x < point.x {
                    self.toolNode!.position = newViewPoint
                } else if newLocation.y > point.y {
                    self.toolNode!.position = newViewPoint
                }
            }
        } else if currentTool != nil && currentTool == .Query {
            // doQueryTool
        }
        
        lastDragPoint = newLocation
    }
    
    override func mouseUp(theEvent: NSEvent) {
        _ = theEvent.locationInNode(self)
        
        dragInProgress = false
        
        if let stroke = currentStroke {
            engine.setToolPreview(nil)
            let location = stroke.getLocation()
            let result = stroke.apply()
            showToolResult(location, result: result)
            currentStroke = nil
            _ = stroke.getBounds().size
            
            setToolCursor()
        }
    }
    
    /// Returns the bottom-left position of a tool cursor with respect to another point
    ///
    /// Returns a point with the range [0, width in tiles] and [0, height in tiles]
    /// This point is relative to the bottom-left corner of the current view
    private func getToolPoint(locationInWorld: CGPoint) -> CGPoint {
        var p = Int(floor(locationInWorld.x) / CGFloat(WorldConstants.TILE_SIZE)) // Adjust for tool center
        var q = Int(floor(locationInWorld.y) / CGFloat(WorldConstants.TILE_SIZE))
        
        // Center the tool on the cursor
        if currentTool != nil && currentTool.size() >= 3 {
            p -= 1
            q -= currentTool.size() - 2
        }
        
        return CGPoint(x: p, y: q)
    }
    
    // MARK: Protocol implementations
    
    func mapAnimation(data: [NSObject : AnyObject]) {
        for animatedTile in animatedTiles {
            redrawTile(animatedTile.x, animatedTile.y)
        }
        
        animatedTiles.removeAll(keepCapacity: true)
    }
    
    func tileChanged(x: Int, y: Int) {
        redrawTile(x, y)
    }
    
    func mapCenterChanged() {
        let viewport = viewportSize
        let topLeft = PointUtils.topLeftMapPoint(engine.currentMapPoint, viewport: viewportSize)

        for y in Int(topLeft.y)..<Int(topLeft.y + viewport.height) {
            for x in Int(topLeft.x)..<Int(topLeft.x + viewport.width) {
                redrawTile(x, y)
            }
        }
    }
    
    func redrawTile(x: Int, _ y: Int) {
        let topLeft = PointUtils.topLeftMapPoint(engine.currentMapPoint, viewport: viewportSize)
        let point = CGPoint(x: x, y: y) - topLeft
        let (arrX, arrY) = (Int(point.x), Int(point.y))
        
        // Bail if tile changed is outside of the viewport (this usually happens due to animation)
        if arrX < 0 || arrY < 0 || arrX > WorldConstants.TILE_WIDTH || arrY > WorldConstants.TILE_WIDTH {
            return
        }
        
        let sprite = tiles[arrY][arrX]
        var tile = engine.city.getTile(x: x, y: y)
        
        if TileConstants.isZoneCenter(tile) && !engine.city.isTilePowered(x: x, y: y) {
            unpoweredTiles.append(CityLocation(x: x, y: y))
            if blink {
                tile = TileConstants.LIGHTNINGBOLT
            }
        }
        
        if let currentPreview = engine.toolPreview {
            let t = currentPreview.getTile(x, y)
            if t != TileConstants.CLEAR {
                tile = t
            }
        }
        
        let (imageNumber, isAnimated) = tileTextures.tileImageInfo.getTileImageInfo(tile, acycle: engine.city.getAnimationCycle())
        
        if isAnimated {
            animatedTiles.append(CityLocation(x: x, y: y))
        }
        
        sprite.texture = tileTextures.textures[imageNumber]
    }
    
    func redrawToolPreview(stroke: ToolStroke, oldPreview: ToolPreview?, newPreview: ToolPreview) {
        // Only redraw the preview if we have to
        if oldPreview == nil || (oldPreview!.width != newPreview.width || oldPreview!.height != newPreview.height) {
            
        }
        
        let bounds = stroke.getBounds()
        let integerBounds = bounds.integral
        let (originX, originY) = (Int(integerBounds.origin.x), Int(integerBounds.origin.y))
        for offsetY in 0 ..< Int(bounds.height) {
            for offsetX in 0 ..< Int(bounds.width) {
                redrawTile(originX + offsetX, originY + offsetY)
            }
        }
    }
    
    private func cityLocationFromClickPoint(eventPoint: CGPoint) -> CityLocation {
        // 1. Find the tile offset from top-left based on click location (set p and q)
        // 2. Find the top left point of the current view (subtract 1/2 tile width/height from current center)
        // 3. Find the map position by adding offsets calculated in 1 to top left calculated in 3
        let viewportPixels = viewportSize * WorldConstants.TILE_SIZE
        let pq = CGPoint(x: Int(floor(eventPoint.x)), y: Int(floor(viewportPixels.height - eventPoint.y))) / WorldConstants.TILE_SIZE
        let topLeft = PointUtils.topLeftMapPoint(engine.currentMapPoint, viewport: viewportSize)
        
        return CityLocation(point: topLeft + pq)
    }
    
    private func setToolCursor(bounds: NSRect? = nil) {
        if currentTool != nil {
            let lastNode = toolNode
            let standardSize = NSSize(width: currentTool.size(), height: currentTool.size())
            let point = bounds.map({$0.origin}).getOrElse(CGPoint.zero)
            let size = bounds.map({$0.size}).getOrElse(standardSize)
            let newRect = NSRect(origin: point, size: size)
            let lastPosition = lastNode.map({$0.position}).getOrElse(CGPoint.zero)
            
            lastNode?.removeFromParent()
            
            toolCursor = ToolCursor(tool: currentTool, withRect: newRect)
            
            engine.toolCursor = toolCursor
            toolNode = ToolNode(size: newRect.size, tileSize: WorldConstants.TILE_SIZE, toolCursor: toolCursor)
            toolNode!.position = lastPosition
            if let ln = lastNode {
                toolNode!.hidden = lastNode!.hidden
            }
            addChild(toolNode!)
        }
    }
    
    private func previewTool() -> ToolPreview? {
        return currentStroke.map { s in
            let preview = s.getPreview()
            self.engine.setToolPreview(preview)
            return preview
        }
    }
    
    private func showToolResult(location: CityLocation, result: ToolResult) {
        switch result {
        case .Success:
            // TODO: should this be in ToolEffect?
            playSound(currentTool == .Bulldozer ? ExplosionSound(isHigh: true) : BuildSound())
            break
        case .None: break
        case .InvalidPosition:
            // TODO show message about bad position
            break
        case .InsufficientFunds:
            // TODO sound + message
            break
        default: break
        }
    }
    
    private func doBlink() {
        if unpoweredTiles.nonEmpty {
            blink = !blink
            for location in unpoweredTiles {
                redrawTile(location.x, location.y)
            }
            
            unpoweredTiles.removeAll(keepCapacity: true)
        }
    }
    
    private func playSound(sound: Sound) {
        playSound(sound.getSoundFilename())
    }
    
    private func playSound(name: String) {
        // TODO "sounds/" should be a constant.
        let soundFile = "sounds/" + name
        runAction(SKAction.playSoundFileNamed(soundFile, waitForCompletion: false))
    }
}
