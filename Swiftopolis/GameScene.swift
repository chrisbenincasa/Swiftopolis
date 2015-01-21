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
    let city = City()
    private let barrier = dispatch_queue_create("com.chrisbenincasa.micropolis", DISPATCH_QUEUE_CONCURRENT)
    
    private var debugOverlay = DebugOverlay()
    private var world: CityWorld = CityWorld()
    private var camera: Camera = Camera()
    private var worldCircle = SKShapeNode(circleOfRadius: 10.0)
    private var cameraCircle = SKShapeNode(circleOfRadius: 10.0)
//    private var atlas: SKTextureAtlas = SKTextureAtlas(named: "images")
    private var tileImages = TileImages.instance
    private var renderedTiles: [[UInt16]] = []
    
    private var width = 0
    private var height = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = NSColor.clearColor()
        
        let cityMap = MapGenerator(city: self.city, width: self.city.map.width, height: self.city.map.height).generateNewCity()
        city.setCityMap(cityMap)
        
        width = city.map.width * TILE_SIZE
        height = city.map.height * TILE_SIZE
        
        Utils.initializeMatrix(&self.renderedTiles, width: city.map.width, height: city.map.height, value: UInt16.max)
        
        city.addSubscriber(self)
        initCursor()
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
        if let mapView = view as? MapView {
            mapView.currentPoint = self.camera.position
        }
        
        view.needsDisplay = true
        view.needsToDrawRect(view.frame)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(world)
        let quarterWidth = width >> 2
        let quarterHeight = height >> 2
        
        let x = location.x <= 0 ? max(-quarterWidth, Int(location.x)) : min(quarterWidth, Int(location.x))
        let y = location.y <= 0 ? max(-quarterHeight, Int(location.y)) : min(quarterHeight, Int(location.y))
        var point = CGPoint(x: x, y: y)
        
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
        self.camera.position = point
        
        if let v = self.view as? MapView {
            v.currentPoint = CGPoint(x: Int(point.x / 16), y: Int(point.y / 16))
            println(CGPoint(x: Int(point.x / 16), y: Int(point.y / 16)))
            v.needsDisplay = true
            v.needsToDrawRect(v.frame)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        self.debugOverlay.removeFromParent()
        self.debugOverlay.removeAllChildren()
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        let cityPoint = getPoint(location)
        let x = Int(cityPoint.x) * TILE_SIZE - 4
        let y = Int(cityPoint.y) * TILE_SIZE - 4
        let newPoint = CGPoint(x: x, y: y)
        if tool!.position != newPoint {
            tool!.position = newPoint
        }
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

        let halfWidth = ((width / 2) / TILE_SIZE)
        let halfHeight = ((height / 2) / TILE_SIZE)
        let xMin = max(-halfWidth, Int(Int(point.x) - halfWidth))
        let xMax = min(halfWidth, Int(Int(point.x) + halfWidth))
        let yMin = max(-halfHeight, Int(Int(point.y) - halfHeight))
        let yMax = min(halfHeight, Int(Int(point.y) + halfHeight))
        
        for var y = yMin; y < yMax; y++ {
            for var x = xMin; x < xMax; x++ {
                let mapX = x + (city.map.width / 2)
                let mapY = y + (city.map.height / 2)
                if let tile = self.city.map.getTile(x: mapX, y: mapY) {
                    if renderedTiles[mapX][mapY] == UInt16.max || renderedTiles[mapX][mapY] != tile {
                        let imageInfo = self.tileImages.getTileImageInfo(Int(tile), acycle: 0)
                        
                        let image = self.tileImages.getImage(imageInfo.imageNumber)
                        let position = CGPoint(x: (x * TILE_SIZE) + (TILE_SIZE / 2), y: y * TILE_SIZE + (TILE_SIZE / 2))
                        let sprite = SKSpriteNode(texture: SKTexture(image: image))
                        sprite.position = position
                        sprite.physicsBody = nil
                        world.addChild(sprite)
                        
                        renderedTiles[mapX][mapY] = tile
                    }
                } else {
                    println("tile not found at (\(x), \(y))")
                }
            }
        }
    }
    
    // MARK: Subscriber Protocol
    
    func citySoundFired(data: [NSObject : AnyObject]) {
        if let sound = data["sound"] as? CitySound {

        }
    }
}
