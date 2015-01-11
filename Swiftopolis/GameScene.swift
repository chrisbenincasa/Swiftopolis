//
//  GameScene.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/27/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    private let TILE_SIZE: Int = 16
    private var tool: SKSpriteNode?
    private let city = City()
    private let barrier = dispatch_queue_create("com.chrisbenincasa.micropolis", DISPATCH_QUEUE_CONCURRENT)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let cityMap = MapGenerator(city: self.city, width: self.city.map.width, height: self.city.map.height).generateNewCity()
        city.setCityMap(cityMap)
        initCursor()
        startSimulationTimer()
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
        let location = theEvent.locationInNode(self)
        let cityLocation = getPoint(location)
        
        let sprite = SKSpriteNode(imageNamed:"com")
        sprite.size = CGSize(width: 3 * TILE_SIZE + 8, height: 3 * TILE_SIZE + 8)
        let x = Int(cityLocation.x) * TILE_SIZE - 4
        let y = Int(cityLocation.y) * TILE_SIZE - 4
        sprite.position = CGPoint(x: x, y: y)
        
        self.addChild(sprite)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
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
    
    private func getPoint(point: CGPoint) -> CGPoint {
        let (newX, newY) = (Int(point.x / CGFloat(TILE_SIZE)), Int(point.y / CGFloat(TILE_SIZE)))
        return CGPoint(x: newX, y: newY)
    }
}
