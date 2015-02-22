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
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var mainView: MainSceneView!
    @IBOutlet var map: MapView!
    @IBOutlet var smallMap: OverlayMapView!
    
    weak var selectedButton: NSButton? = nil
    
    // MARK: Tool Button outlets
    @IBOutlet weak var dozerButton: NSButton!
    @IBOutlet weak var powerButton: NSButton!
    @IBOutlet weak var parkButton: NSButton!
    @IBOutlet weak var roadButton: NSButton!
    @IBOutlet weak var railButton: NSButton!
    @IBOutlet weak var resButton: NSButton!
    @IBOutlet weak var comButton: NSButton!
    @IBOutlet weak var indButton: NSButton!
    @IBOutlet weak var fireButton: NSButton!
    @IBOutlet weak var queryButton: NSButton!
    @IBOutlet weak var policeButon: NSButton!
    @IBOutlet weak var coalButon: NSButton!
    @IBOutlet weak var nuclearButon: NSButton!
    @IBOutlet weak var stadiumButon: NSButton!
    @IBOutlet weak var seaportButon: NSButton!
    @IBOutlet weak var airportButon: NSButton!
    
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
        map = MapView(tileSize: 16, engine: engine, frame: baseFrame)
        mainView.addSubview(map)
        mainView.map = map
        mainView.engine = engine
        
        // Set up game scene
        initGameScene()
        
        // Set up small map
        smallMap.engine = engine
        smallMap.connectedView = mainView
        
        // Redraw
        mainView.needsDisplay = true
        smallMap.needsDisplay = true
    }
 
    @IBAction func regenerate(sender: AnyObject!) {
        
    }
    
    // MARK: Tool functions
    @IBAction func useResidentialZoneTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Residential)
    }
    
    @IBAction func useCommercialZoneTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Commercial)
    }
    
    @IBAction func useIndustrailZoneTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Industrial)
    }
    
    @IBAction func useBulldozerTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Bulldozer)
    }
    
    @IBAction func useParkTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Park)
    }
    
    @IBAction func useWireTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Wire)
    }
    
    @IBAction func useRoadTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Road)
    }
    
    @IBAction func useRailTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Rail)
    }
    
    @IBAction func useFireStationTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.FireStation)
    }
    
    @IBAction func usePoliceStationTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.PoliceStation)
    }
    
    @IBAction func useQueryTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Query)
    }
    
    @IBAction func useCoalTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Coal)
    }
    
    @IBAction func useNuclearTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Nuclear)
    }
    
    @IBAction func useAirportTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Airport)
    }
    
    @IBAction func useSeaportTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Seaport)
    }
    
    private func swapSelectedButton(button: NSButton) {
        selectedButton.map(setButtonAsUnselected)
        setButtonAsSelected(button)
        selectedButton = button
    }
    
    func timerFired() {
        updateDateLabel()
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
    
    private func setButtonAsSelected(button: NSButton) {
        if let originalName = button.image?.name() {
            let newName = originalName + "hi"
            button.image = NSImage(named: newName)
        }
    }
    
    private func setButtonAsUnselected(button: NSButton) {
        if var originalName = button.image?.name() {
            if originalName.hasSuffix("hi") {
                originalName.removeRange(advance(originalName.endIndex, -2)...advance(originalName.endIndex, -1))
                button.image = NSImage(named: originalName)
            }
        }
    }
    
    private func initGameScene() {
        let scene = GameScene(engine: engine, size: mainView.frame.size)
        // Set up SKView
        self.mainView!.allowsTransparency = true
        
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
