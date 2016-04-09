//
//  GameViewController.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/20/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class GameViewController: NSViewController, EngineEventListener {
    private var engine: Engine!
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var mainView: MainSceneView!
    
    @IBOutlet weak var dateLabel: NSTextField!
    
    private var currentSpeedMenuItem: NSMenuItem?
    @IBOutlet weak var superFastItem: NSMenuItem!
    @IBOutlet weak var fastItem: NSMenuItem!
    @IBOutlet weak var normalItem: NSMenuItem!
    @IBOutlet weak var slowItem: NSMenuItem!
    @IBOutlet weak var pausedItem: NSMenuItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the game engine instance and start injecting it
        engine = Engine()
        
        engine.registerListener(self)
        
        // TODO load this different, better, something
        _ = NSDate()
        let tileLoader = TileJsonLoader()
        tileLoader.readTiles(NSBundle.mainBundle().pathForResource("tiles", ofType: "json")!)
        _ = NSDate()
//        let timeInterval: Double = end.timeIntervalSinceDate(start)
        
        let cityMap = MapGenerator(city: engine.city, width: engine.city.map.width, height: engine.city.map.height).generateNewCity()
        engine.city.setCityMap(cityMap)
        
        // TODO: factor out view construction
        var baseFrame = mainView.frame
        baseFrame.origin = CGPoint.zero
        mainView.engine = engine
        
        // Set up game scene
        initGameScene()
        
        gameSpeedChanged(engine.city.speed)
    }
    
    @IBAction func setSuperFastGameSpeed(sender: AnyObject!) {
        gameSpeedChanged(ExtremeSpeed())
    }
    
    @IBAction func setFastGameSpeed(sender: AnyObject!) {
        gameSpeedChanged(FastSpeed())
    }
    
    @IBAction func setNormalGameSpeed(sender: AnyObject!) {
        gameSpeedChanged(NormalSpeed())
    }
    
    @IBAction func setSlowGameSpeed(sender: AnyObject!) {
        gameSpeedChanged(SlowSpeed())
    }
    
    @IBAction func setPausedGameSpeed(sender: AnyObject!) {
        gameSpeedChanged(PausedSpeed())
    }
    
    func gameSpeedChanged(newSpeed: Speed) {
        let lastSpeedItem = currentSpeedMenuItem
        engine.city.setGameSpeed(newSpeed)
        if setCurrentSpeedItem() {
            lastSpeedItem?.state = 0
            currentSpeedMenuItem?.state = 1
        }
    }
    
    private func setCurrentSpeedItem() -> Bool {
        var changed = true
        switch engine.city.speed {
        case is PausedSpeed:
            currentSpeedMenuItem = pausedItem
            break
        case is SlowSpeed:
            currentSpeedMenuItem = slowItem
            break
        case is NormalSpeed:
            currentSpeedMenuItem = normalItem
            break
        case is FastSpeed:
            currentSpeedMenuItem = fastItem
            break
        case is ExtremeSpeed:
            currentSpeedMenuItem = superFastItem
            break
        default:
            changed = false
            break
        }
        
        return changed
    }
    
    private func initGameScene() {
        let scene = GameScene(engine: engine, size: mainView.frame.size)
        // Set up SKView
        self.mainView!.allowsTransparency = true
        
        self.mainView!.showsFPS = true
        self.mainView!.showsDrawCount = true
        self.mainView!.showsNodeCount = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .ResizeFill
        
        self.mainView!.presentScene(scene)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.mainView!.ignoresSiblingOrder = true
        self.mainView!.asynchronous = true
        
        window.acceptsMouseMovedEvents = true
        window.makeFirstResponder(self.mainView.scene)
    }
}
