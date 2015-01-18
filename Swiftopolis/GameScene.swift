//
//  GameScene.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/27/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import SpriteKit
import OpenGL
import GLKit
import GLUT

class GameScene: SKScene, Subscriber {
    private let TILE_SIZE: Int = 16
    private var tool: SKSpriteNode?
    private let city = City()
    private let barrier = dispatch_queue_create("com.chrisbenincasa.micropolis", DISPATCH_QUEUE_CONCURRENT)
    
    private var debugOverlay = DebugOverlay()
    private var world: CityWorld = CityWorld()
    private var camera: Camera = Camera()
    private var worldCircle = SKShapeNode(circleOfRadius: 10.0)
    private var cameraCircle = SKShapeNode(circleOfRadius: 10.0)
    private var atlas: SKTextureAtlas = SKTextureAtlas(named: "images")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let cityMap = MapGenerator(city: self.city, width: self.city.map.width, height: self.city.map.height).generateNewCity()
        city.setCityMap(cityMap)
        city.addSubscriber(self)
//        initCursor()
//        startSimulationTimer()
        
        // Turn off gravity
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.addChild(debugOverlay)

        world.name = "world"
        self.addChild(worldCircle)
        self.addChild(world)
        self.camera.name = "camera"
        world.addChild(camera)
        world.addChild(cameraCircle)
        
        drawGrid()
        drawTiles(CGPoint(x: 0, y: 0))
    }
    
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
    
    private func initCursor() {
        tool = SKSpriteNode(imageNamed: "com")
        tool!.size = CGSize(width: 3 * TILE_SIZE + 8, height: 3 * TILE_SIZE + 8)
        self.addChild(tool!)
    }
    
    override func didMoveToView(view: SKView) {

    }
    
    override func mouseDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(world)
        var x: CGFloat = 0, y: CGFloat = 0
        if location.x <= 0 {
//            println(ceil(-self.size.width/2))
            x = max(ceil(-1024/2), location.x)
        } else {
            x = min(1024/2, location.x)
        }
        
        if location.y <= 0 {
            y = max(-1024/2, location.y)
        } else {
            y = min(1024/2, location.y)
        }
        
        self.camera.position = CGPoint(x: x, y: y)
        
        drawTiles(CGPoint(x: x, y: y))
    }
    
    override func update(currentTime: CFTimeInterval) {
        self.debugOverlay.removeFromParent()
        self.debugOverlay.removeAllChildren()
    }
    
    override func mouseMoved(theEvent: NSEvent) {
//        let location = theEvent.locationInNode(self)
//        let cityPoint = getPoint(location)
//        let x = Int(cityPoint.x) * TILE_SIZE - 4
//        let y = Int(cityPoint.y) * TILE_SIZE - 4
//        let newPoint = CGPoint(x: x, y: y)
//        if tool!.position != newPoint {
//            tool!.position = newPoint
//        }
    }

    override func didFinishUpdate() {
        centerOnCamera()
        
        self.addChild(debugOverlay)
        
        cameraCircle.fillColor = NSColor.redColor()
        cameraCircle.position = camera.position
        
        worldCircle.fillColor = NSColor.blueColor()
        worldCircle.position = world.position
    }
    
    private func getPoint(point: CGPoint) -> CGPoint {
        let (newX, newY) = (Int(point.x / CGFloat(TILE_SIZE)), Int(point.y / CGFloat(TILE_SIZE)))
        return CGPoint(x: newX, y: newY)
    }
    
    private func centerOnCamera() {
        let cameraPosition = self.convertPoint(camera.position, fromNode: world)
        world.position = CGPoint(x: world.position.x - cameraPosition.x, y: world.position.y - cameraPosition.y)
    }
    
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
    
    private func drawTiles(point: CGPoint) {
        let cameraPositionToWorld = self.convertPoint(camera.position, fromNode: world)
        let cameraPositionToScene = self.convertPoint(camera.position, fromNode: self)
        let worldPosition = self.convertPoint(world.position, fromNode: self)
        
        let center = CGPoint(x: Int(cameraPositionToWorld.x) / TILE_SIZE, y: Int(cameraPositionToWorld.y) / TILE_SIZE)

        let xMin = Int(Int(point.x) - ((64 / 2) / TILE_SIZE))
        let xMax = Int(Int(point.x) + ((64 / 2)) / TILE_SIZE)
        let yMin = Int(Int(point.y) - ((64 / 2)) / TILE_SIZE)
        let yMax = Int(Int(point.y) + ((64 / 2)) / TILE_SIZE)
        
        for var y = yMin; y < yMax; y++ {
            for var x = xMax - 1; x >= xMin; x-- {
                let comTexture = atlas.textureNamed("com")
                let s = SKSpriteNode(texture: comTexture)
                s.position = CGPoint(x: (x * TILE_SIZE) - (TILE_SIZE / 2), y: y * TILE_SIZE - (TILE_SIZE / 2))
                s.blendMode = .Replace
                s.texture!.filteringMode = .Nearest
                world.addChild(s)
            }
        }
    }
    
    // MARK: Subscriber Protocol
    
    func citySoundFired(data: [NSObject : AnyObject]) {
        if let sound = data["sound"] as? CitySound {

        }
    }
}
