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
            initCursor()
        }
    }
    private var toolNode: SKShapeNode?
    
    private var city: City!
    private let barrier = dispatch_queue_create("com.chrisbenincasa.micropolis", DISPATCH_QUEUE_CONCURRENT)
    
    private var debugOverlay = DebugOverlay()
    private var world: CityWorld = CityWorld()
    private var camera: Camera = Camera()
    private var worldCircle = SKShapeNode(circleOfRadius: 10.0)
    private var cameraCircle = SKShapeNode(circleOfRadius: 10.0)
    
    private var pixelWidth = 0
    private var pixelHeight = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init(city: City) {
        super.init()
        self.city = city
        commonInit()
    }
    
    init(city: City, size: CGSize) {
        super.init(size: size)
        self.city = city
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
        // startSimulationTimer()
        
        // Turn off gravity
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        // Set anchor point to the middle of the screen
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // DEBUG
        self.addChild(debugOverlay)
        debugOverlay.addChild(worldCircle)
        debugOverlay.addChild(cameraCircle)
        
        // Create main nodes
        // World represents the city and camera is the viewpoint.
        world.name = "world"
        self.addChild(world)
        self.camera.name = "camera"
        world.addChild(camera)
        println("world started at \(world.position)")
    }
    
    // MARK: Overrides and Animation
    
    override func didMoveToView(view: SKView) {
        if let mapView = view as? MainSceneView {
            println("what")
            mapView.currentPoint = self.camera.position
            mapView.city = self.city
        }
        
        view.needsDisplay = true
        view.needsToDrawRect(view.frame)
    }
    
    override func update(currentTime: CFTimeInterval) {
        self.debugOverlay.removeFromParent()
        self.debugOverlay.removeAllChildren()
    }
    
    override func didFinishUpdate() {
        centerOnCamera()
        
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
            let cityPoint = getPoint(location)
            let x = Int(cityPoint.x) * TILE_SIZE - 4
            let y = Int(cityPoint.y) * TILE_SIZE - 4
            let newPoint = CGPoint(x: x, y: y)
            if tool.position != newPoint {
                tool.position = newPoint
            }
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(world)
        
        /* Uncomment for camera move animation
        let moveAction = SKAction.moveTo(point, duration: 1.0)
        moveAction.timingMode = .EaseIn
        let drawAction = SKAction.customActionWithDuration(1.0, actionBlock: { (node, elapsed) -> Void in
        if let v = self.view as? MapView {
        v.currentPoint = CGPoint(x: node.position.x / 16.0, y: node.position.y / 16.0)
        //                println(CGPoint(x: Int(point.x / 16), y: Int(point.y / 16)))
        v.needsDisplay = true
        v.needsToDrawRect(v.frame)
        }
        })
        let group = SKAction.group([moveAction, drawAction])
        self.camera.runAction(group)
        */
        
        // convert to map point
        let x = (Int(location.x) / TILE_SIZE) + (city.map.width >> 1)
        let y = (city.map.height >> 1) - (Int(location.y) / TILE_SIZE)
        
        // This is still a little busted because we don't validate/normalize the point we set to the new camera
        // location, so you can keep clicking but the map won't move
        // The map validates/normalizes the requested point to draw around, but we set blindly
        // TODO: Factor out the validation methods so we can use them here before blindly setting the camera point
        self.camera.position = location
        
        if let v = self.view as? MainSceneView {
            v.currentPoint = CGPoint(x: x, y: y)
            v.needsDisplay = true
            v.needsToDrawRect(v.frame)
        }

    }
    
    // MARK: Simulation Helpers
    
    private func startSimulationTimer() {
        let delay: Double = Double(self.city.speed.delay) / 1000.0
        var wait = SKAction.waitForDuration(delay)
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
        for var x = -64, y = 0; x <= 64; x += TILE_SIZE, y++ {
            var path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, CGFloat(x), 64)
            CGPathAddLineToPoint(path, nil, CGFloat(x), -64)
            let node = SKShapeNode(path: path)
            if x == -64 || x == 64 {
                node.strokeColor = NSColor.redColor()
            } else {
                node.strokeColor = NSColor.blackColor()
            }
            world.addChild(node)
        }
        
        for var y = -64, x = 0; y <= 64; y += TILE_SIZE, x++ {
            var path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, -64, CGFloat(y))
            CGPathAddLineToPoint(path, nil, 64, CGFloat(y))
            let node = SKShapeNode(path: path)
            
            if y == -64 || y == 64 {
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
    
    private func initCursor() {
        if currentTool != nil {
            let lastNode = toolNode
            let lastPosition = lastNode != nil ? lastNode!.position : NSPoint(x: 0, y: 0)
            let newRect = NSRect(origin: NSPoint(x: 0, y: 0), size: NSSize(width: currentTool.size(), height: currentTool.size()))
            toolCursor = ToolCursor.toolCursorForTool(currentTool, rect: newRect)
            toolNode = makeToolCursor()
            toolNode!.position = lastPosition
            self.addChild(toolNode!)
        }
    }
    
    private func makeToolCursor() -> SKShapeNode {
        let shapeRect = NSRect(x: 0, y: 0, width: currentTool.size() * TILE_SIZE, height: currentTool.size() * TILE_SIZE)
        toolNode = SKShapeNode(rect: shapeRect)
        toolNode!.fillColor = toolCursor.fillColor
        toolNode!.lineWidth = 2.0
        toolNode!.glowWidth = 0.5
        toolNode!.strokeColor = toolCursor.borderColor

        return toolNode!
    }
    
    // MARK: Subscriber Protocol
    
    func citySoundFired(data: [NSObject : AnyObject]) {
        if let sound = data["sound"] as? Sound {
            println("sound fired!")
        }
    }
}
