//
//  GameScene.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/27/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, Subscriber {
    private let TILE_SIZE: Int = 16
    
    private var toolCursor: ToolCursor!
    private var currentTool: Tool! {
        didSet {
            setToolCursor()
        }
    }
    private var currentStroke: ToolStroke?
    private var toolNode: SKShapeNode?
    
    private var engine: Engine!
    
    // Convenience accessor for city
    private var city: City {
        get {
            return engine.city
        }
    }
    private let barrier = dispatch_queue_create("com.chrisbenincasa.micropolis", DISPATCH_QUEUE_SERIAL)
    
    private var debugOverlay = DebugOverlay()
    private var world: CityWorld = CityWorld()
    private var camera: Camera = Camera()
    private var worldCircle = SKShapeNode(circleOfRadius: 10.0)
    private var cameraCircle = SKShapeNode(circleOfRadius: 10.0)
    
    private var pixelWidth = 0
    private var pixelHeight = 0
    
    private var lastPoint: CityLocation?
    private var dragInProgress = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init(engine: Engine) {
        super.init()
        self.engine = engine
        commonInit()
    }
    
    init(engine: Engine, size: CGSize) {
        super.init(size: size)
        self.engine = engine
        commonInit()
    }
    
    private func commonInit() {
        // Make the background clear to the drawn map underneath shows
        self.backgroundColor = NSColor.clearColor()
        
        // Generate a new map and assign it to the city
        // TODO: This should be factored out of the scene
        let cityMap = MapGenerator(city: self.city, width: self.city.map.width, height: self.city.map.height).generateNewCity()
        city.setCityMap(cityMap)
        
        // Save the pixel dimensions of the map
        pixelWidth = city.map.width * TILE_SIZE
        pixelHeight = city.map.height * TILE_SIZE
        self.size = NSSize(width: pixelWidth, height: pixelHeight)
        
        // Listen for city events
        city.addSubscriber(self)
        
        // Start the simulation
        startSimulationTimer()
        
        // Turn off gravity
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        // Set anchor point to the middle of the screen
//        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // DEBUG
        worldCircle.fillColor = NSColor.greenColor()
        self.addChild(debugOverlay)
        debugOverlay.addChild(worldCircle)
        debugOverlay.addChild(cameraCircle)
        drawGrid()
        
        // Create main nodes
        // World represents the city and camera is the viewpoint.
        world.name = "world"
        self.addChild(world)
        self.camera.name = "camera"
        world.addChild(camera)
    }
    
    // MARK: Overrides and Animation
    
    override func didMoveToView(view: SKView) {
//        if let mapView = view as? MainSceneView {
//            mapView.city = self.city
//        }
        
        view.needsDisplay = true
    }
    
    override func update(currentTime: CFTimeInterval) {
        self.debugOverlay.removeFromParent()
        self.debugOverlay.removeAllChildren()
    }
    
    override func didFinishUpdate() {
//        centerOnCamera()
        
        self.addChild(debugOverlay)
        
        cameraCircle.fillColor = NSColor.redColor()
        cameraCircle.position = camera.position
        
        worldCircle.fillColor = NSColor.blueColor()
        worldCircle.position = world.position
    }
    
    // MARK: Mouse Events
    
    override func mouseMoved(theEvent: NSEvent) {
        // TODO toss events that are out of the bounds of the scene
        if var tool = toolNode {
            let location = theEvent.locationInNode(self)
            var newPoint = getToolPoint(location)
            
            let cityLocation = cityLocationFromClickPoint(location)
            
            if tool.position != newPoint {
                tool.position = newPoint
            }
            
            setToolCursor(bounds: NSRect(x: cityLocation.x, y: cityLocation.y, width: currentTool.size(), height: currentTool.size()))
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        if currentTool == nil {
            return
        }
        
        dragInProgress = true
        
        let location = theEvent.locationInNode(self)
        
        // 1. Find the tile offset from top-left based on click location (set p and q)
        // 2. Find the top left point of the current view (subtract 1/2 tile width/height from current center)
        // 3. Find the map position by adding offsets calculated in 1 to top left calculated in 3
        let p = Int(floor(location.x) / CGFloat(TILE_SIZE))
        let q = Int(floor((view!.frame.height) - location.y) / CGFloat(TILE_SIZE))
        let point = engine.currentMapPoint
        let halfViewportSizeInTiles = (Int(view!.frame.width) / TILE_SIZE) >> 1
        let topLeft = CGPoint(x: Int(point.x) - halfViewportSizeInTiles, y: Int(point.y) - halfViewportSizeInTiles)
        let x = Int(topLeft.x) + p
        let y = Int(topLeft.y) + q
        let newLocation = cityLocationFromClickPoint(location)
        
        if lastPoint.isDefined() && lastPoint == newLocation {
            return
        }
        
        if let stroke = currentStroke {
            stroke.dragTo(x, y)
            previewTool()
            var strokeBounds = stroke.getBounds()
            let newPoint = getToolPoint(location)
            
            setToolCursor(bounds: stroke.getBounds())
            
            // Update toolNode position if we're moving west -> east or north -> south
            lastPoint.foreach { point in
                if newLocation.x < point.x {
                    self.toolNode!.position = newPoint
                } else if newLocation.y > point.y {
                    self.toolNode!.position = newPoint
                }
            }
            
            // Invalidate the map view
            (view as? MainSceneView).foreach { v in
                v.mapNeedsDisplay()
            }
        } else if currentTool != nil && currentTool == .Query {
            // doQueryTool
        }
        
        lastPoint = newLocation
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        
        // convert to map point
        // TODO: fix this up because this implementation is terrible.
        // There's no way we should have to do calculations like this in each method
        // Normalize coordinate systems and make them easily convertable between each other
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
                // The point that was clicked represents the center of the current tool, but strokes begin in the top-left
                // of the tool. Because of this, we adjust the point passed in so it matches what the preview is showing
                currentStroke = currentTool.beginStroke(city, x: cityLocation.x, y: cityLocation.y)
                previewTool()
            }
            
            break
        case 2: break
        default: // any other button
            // This is still a little busted because we don't validate/normalize the point we set to the new camera
            // location, so you can keep clicking but the map won't move
            // The map validates/normalizes the requested point to draw around, but we set blindly
            // TODO: Factor out the validation methods so we can use them here before blindly setting the camera point
            println("clicked \(pressedButtons)")
            
            if let v = self.view as? MainSceneView {
                v.mapNeedsDisplay()
            }
            break
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        let eventLocation = theEvent.locationInNode(self)
        
        let p = Int(floor(eventLocation.x) / CGFloat(TILE_SIZE))
        let q = Int(floor((view!.frame.height) - eventLocation.y) / CGFloat(TILE_SIZE))
        
        dragInProgress = false
        
        if let stroke = currentStroke {
            let location = stroke.getLocation()
            let result = stroke.apply()
            showToolResult(location, result: result)
            currentStroke = nil
            setToolCursor()
            println(result.toString())
        }
     
        view?.needsDisplay = true
    }
    
    // MARK: Simulation Helpers
    
    private func startSimulationTimer() {
        let delay: Double = Double(self.city.speed.delay) / 1000.0
        var wait = SKAction.waitForDuration(delay)
        engine.startTimers()
        var run = SKAction.runBlock({
            let speed = self.city.speed
            for _ in 0...speed.steps - 1 {
                self.city.animate()
            }
        }, queue: barrier)
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([wait, run])), withKey: "simulation")
    }
    
    private func stopSimulationTimer() {
        if let action = self.actionForKey("simulation") {
            self.removeActionForKey("simulation")
        }
    }
    
    // MARK: Position Helpers
    
    private func getPoint(point: CGPoint) -> CGPoint {
        return CGPoint(x: Int(point.x) / TILE_SIZE, y: Int(point.y) / TILE_SIZE)
    }
    
    private func centerOnCamera() {
        let cameraPosition = self.convertPoint(camera.position, fromNode: world)
        world.position = CGPoint(x: world.position.x - cameraPosition.x, y: world.position.y - cameraPosition.y)
    }
    
    // MARK: Drawing Helpers
    
    private func drawGrid() {
        for var x = -Int(frame.width/2), y = 0; x <= Int(frame.width/2); x += TILE_SIZE, y++ {
            var path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, CGFloat(x), frame.width)
            CGPathAddLineToPoint(path, nil, CGFloat(x), -frame.width)
            let node = SKShapeNode(path: path)
            if x == 0 {
                node.strokeColor = NSColor.greenColor()
            } else if x % 5 == 0 {
                node.strokeColor = NSColor.redColor()
            } else {
                node.strokeColor = NSColor.blackColor()
            }
            world.addChild(node)
        }
        
        for var y = -Int(frame.height/2), x = 0; y <= Int(frame.height/2); y += TILE_SIZE, x++ {
            var path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, -frame.height, CGFloat(y))
            CGPathAddLineToPoint(path, nil, frame.height, CGFloat(y))
            let node = SKShapeNode(path: path)
            
            if y == 0 {
                node.strokeColor = NSColor.greenColor()
            } else if y % 5 == 0 {
                node.strokeColor = NSColor.redColor()
            } else {
                node.strokeColor = NSColor.blackColor()
            }
            world.addChild(node)
        }
    }
    
    // MARK: Tool Cursor
    
    func setCurrentTool(tool: Tool) {
        self.currentTool = tool
    }
    
    private func getToolPoint(locationInWorld: CGPoint) -> CGPoint {
        var p = Int(floor(locationInWorld.x) / CGFloat(TILE_SIZE)) // Adjust for tool center
        var q = Int(floor(locationInWorld.y) / CGFloat(TILE_SIZE))
        
        // Center the tool on the cursor
        if currentTool != nil && currentTool.size() >= 3 {
            p -= currentTool.size() / 2
            q -= currentTool.size() / 2
        }
        
        return CGPoint(x: p * TILE_SIZE, y: q * TILE_SIZE)
    }
    
    private func setToolCursor(bounds: NSRect? = nil) {
        if currentTool != nil {
            let lastNode = toolNode
            let standardSize = NSSize(width: currentTool.size(), height: currentTool.size())
            let point = bounds == nil ? NSPoint.zeroPoint : bounds!.origin
            let size = bounds?.size == nil ? standardSize : bounds!.size
            let newRect = NSRect(origin: point, size: size)
            let lastPosition = lastNode != nil ? lastNode!.position : NSPoint.zeroPoint
            
            lastNode?.removeFromParent()
            
            toolCursor = ToolCursor(tool: currentTool, withRect: newRect)
            toolNode = makeToolCursor(newRect)
            toolNode!.position = lastPosition
            world.addChild(toolNode!)
        }
    }
    
    private func makeToolCursor(rect: NSRect) -> SKShapeNode {
        let shapeRect = NSRect(x: 0, y: 0, width: Int(rect.size.width) * TILE_SIZE, height: Int(rect.size.height) * TILE_SIZE)
        toolNode = SKShapeNode(rect: shapeRect)
        toolNode!.fillColor = toolCursor.fillColor
        toolNode!.lineWidth = 2.0
        toolNode!.glowWidth = 0.5
        toolNode!.strokeColor = toolCursor.borderColor

        return toolNode!
    }
    
    private func previewTool() {
        if let stroke = currentStroke {
            let preview = stroke.getPreview()
            engine.setToolPreview(preview)
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
    
    private func cityLocationFromClickPoint(eventPoint: CGPoint) -> CityLocation {
        // 1. Find the tile offset from top-left based on click location (set p and q)
        // 2. Find the top left point of the current view (subtract 1/2 tile width/height from current center)
        // 3. Find the map position by adding offsets calculated in 1 to top left calculated in 3
        let p = Int(floor(eventPoint.x) / CGFloat(TILE_SIZE))
        let q = Int(floor((view!.frame.height) - eventPoint.y) / CGFloat(TILE_SIZE))
        let point = engine.currentMapPoint
        let halfViewportSizeInTiles = (Int(view!.frame.width) / TILE_SIZE) >> 1
        let topLeft = CGPoint(x: Int(point.x) - halfViewportSizeInTiles, y: Int(point.y) - halfViewportSizeInTiles)
        
        return CityLocation(x: Int(topLeft.x) + p, y: Int(topLeft.y) + q)
    }
    
    // MARK: Subscriber Protocol
    
    func citySoundFired(data: [NSObject : AnyObject]) {
        if let sound = data["sound"] as? Sound {
            playSound(sound)
        }
    }
    
    // MARK: Private helpers
    
    private func playSound(sound: Sound) {
        self.playSound(sound.getSoundFilename())
    }
    
    private func playSound(name: String) {
        // TODO "sounds/" should be a constant.
        let soundFile = "sounds/" + name
        runAction(SKAction.playSoundFileNamed(soundFile, waitForCompletion: false))
    }
    
    private func topLeftMapPoint() -> CGPoint {
        let point = engine.currentMapPoint
        let halfViewportSizeInTiles = (Int(view!.frame.width) / TILE_SIZE) >> 1
        return point - halfViewportSizeInTiles
    }
}
