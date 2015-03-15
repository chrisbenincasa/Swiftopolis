//
//  GameScene.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/27/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, Subscriber, EngineEventListener {
    private let TILE_SIZE: Int = 16
    
    private var toolCursor: ToolCursor!
    private var currentTool: Tool! {
        didSet {
            self.world.currentTool = self.currentTool
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
    private var _timer: dispatch_source_t!
    private var blinkTimer: dispatch_source_t!
    private var dateTimer: dispatch_source_t!
    
    private var debugOverlay = DebugOverlay()
    private var world: CityWorld!
    private var overlayMap: OverlayMap!
    private var camera: Camera = Camera()
    private var cityDate: CityDateNode!
    private var demandIndicator: DemandIndicator!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init(engine _engine: Engine) {
        super.init()
        engine = _engine
        commonInit()
    }
    
    init(engine _engine: Engine, size _size: CGSize) {
        super.init(size: _size)
        engine = _engine
        commonInit()
    }
    
    private func commonInit() {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, barrier)
        blinkTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
        dateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
        
        world = CityWorld(engine: engine)
        overlayMap = OverlayMap(engine: engine, connectedMap: world)
        cityDate = CityDateNode(initialCityTime: engine.city.cityTime)
        cityDate.verticalAlignmentMode = .Bottom
        
        // Make the background clear to the drawn map underneath shows
        backgroundColor = NSColor.clearColor()
        
        // Listen for city events
        city.addSubscriber(self)
        
        engine.registerListener(self)
        
        // Start the simulation
        startSimulationTimer()
        
        // Turn off gravity
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        // DEBUG
//        debugOverlay.buildGrid(TILE_SIZE)
//        debugOverlay.attachToNode(world)
//        debugOverlay.zPosition = 1000
        
        // Create main nodes
        // World represents the city and camera is the viewpoint.
        world.name = "world"
        world.position = CGPoint(x: 496, y: 96)
        addChild(world)
        camera.name = "camera"
        world.addChild(camera)
        
        let panel = ToolButtonPanel()
        panel.position = CGPoint(x: world.position.x - 127, y: frame.height - 100)
        addChild(panel)
        
        overlayMap.position = CGPoint(x: 0, y: frame.height - 400)
        addChild(overlayMap)
        overlayMap.draw()
        overlayMap.connectedMap = world
        
        cityDate.position = CGPoint(x: overlayMap.position.x + 320, y: overlayMap.position.y + 300 + 10)
        addChild(cityDate)
        
        demandIndicator = DemandIndicator(texture: SKTexture(imageNamed: "demandg"), color: NSColor.clearColor(), size: CGSize(width: 39, height: 47))
        demandIndicator.position = CGPoint(x: overlayMap.position.x, y: overlayMap.position.y + 300 + 10)
        engine.city.addSubscriber(demandIndicator)
        addChild(demandIndicator)
    }
    
    // MARK: Mouse Events
    
    override func cancelOperation(sender: AnyObject?) {
        engine.setToolPreview(nil)
    }
    
    // MARK: Simulation Helpers
    
    private func startSimulationTimer() {
        let delay: Double = Double(self.city.speed.delay) / 1000.0
        engine.startTimers()
        
        let delayNano = UInt64(city.speed.delay) * NSEC_PER_MSEC
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, delayNano, delayNano / 2)
        dispatch_source_set_event_handler(_timer) { [unowned self] in
            let speed = self.city.speed
            for _ in 0...speed.steps - 1 {
                self.city.animate()
            }
        }
        // Start the timer
        dispatch_resume(_timer)
        
        dispatch_source_set_timer(blinkTimer, DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC, 10)
        dispatch_source_set_event_handler(blinkTimer) { [unowned self] in

        }
        
        dispatch_resume(blinkTimer)
        
        let cityAnimDelay = UInt64((Double(city.speed.delay) / 1000.0) * Double(NSEC_PER_SEC))
        let other = UInt64(0.25 * Double(NSEC_PER_SEC))
        dispatch_source_set_timer(dateTimer, DISPATCH_TIME_NOW, cityAnimDelay, other)
        dispatch_source_set_event_handler(dateTimer) { [unowned self] in
            self.cityDate.updateText(self.engine.city.cityTime)
        }
        
        dispatch_resume(dateTimer)
    }
    
    private func stopSimulationTimer() {
        dispatch_suspend(_timer)
    }
    
    // MARK: Tool Cursor
    func setCurrentTool(tool: Tool) {
        self.currentTool = tool
    }
    
    func clearCurrentTool() {
        self.currentTool = nil
    }
    
    // MARK: Subscriber Protocol
    
    func citySoundFired(data: [NSObject : AnyObject]) {
        if let sound = data["sound"] as? Sound {
            playSound(sound)
        }
    }
    
    func mapAnimation(data: [NSObject : AnyObject]) {
        if let v = view as? MainSceneView {
//            v.animateTiles()
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
    
    private func viewportSize() -> CGSize {
        return view!.frame.size / TILE_SIZE
    }
}
