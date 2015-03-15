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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the game engine instance and start injecting it
        engine = Engine()
        
        engine.registerListener(self)
        
        // TODO load this different, better, something
        let start = NSDate()
        let tileLoader = TileJsonLoader()
        tileLoader.readTiles(NSBundle.mainBundle().pathForResource("tiles", ofType: "json")!)
        let end = NSDate()
        let timeInterval: Double = end.timeIntervalSinceDate(start)
        
        let cityMap = MapGenerator(city: engine.city, width: engine.city.map.width, height: engine.city.map.height).generateNewCity()
        engine.city.setCityMap(cityMap)
        
        // TODO: factor out view construction
        var baseFrame = mainView.frame
        baseFrame.origin = CGPoint.zeroPoint
        mainView.engine = engine
        
        // Set up game scene
        initGameScene()
    }
    
    private func updateDateLabel() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        let time = self.engine.city.cityTime
        components.year = 1900 + time / 48
        components.month = (time % 48) / 4
        components.day = (time % 4) * 7 + 1
//        println(components)
        
        // Ensure UI update happens on main thread
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.dateLabel.stringValue = formatter.stringFromDate(calendar.dateFromComponents(components)!)
        }
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
