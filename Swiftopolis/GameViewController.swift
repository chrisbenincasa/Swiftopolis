//
//  GameViewController.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/20/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class GameViewController: NSViewController {
    private var city = City()
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var mainView: MainSceneView!
    @IBOutlet var map: MapView!
    @IBOutlet var smallMap: OverlayMapView!
    
    weak var selectedButton: NSButton? = nil
    
    // Tool Buttons
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO load this different, better, something
        let start = NSDate()
        let tileLoader = TileJsonLoader()
        tileLoader.readTiles(NSBundle.mainBundle().pathForResource("tiles", ofType: "json")!)
        let end = NSDate()
        let timeInterval: Double = end.timeIntervalSinceDate(start)
        
        let cityMap = MapGenerator(city: city, width: city.map.width, height: city.map.height).generateNewCity()
        city.setCityMap(cityMap)
        
        // TODO: factor out view construction
        var baseFrame = mainView.frame
        baseFrame.origin = CGPoint(x: 0, y: 0)
        map = MapView(tileSize: 16, city: city, frame: baseFrame)
        mainView.addSubview(map)
        mainView.city = city
        
        // TODO: factor out game scene creation
        let scene = GameScene(city: city, size: self.mainView.frame.size)
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
        
        mainView.needsDisplay = true
        mainView.needsToDrawRect(map.frame)

        // Set up small map
        smallMap.city = city
        smallMap.connectedView = map
        smallMap.needsDisplay = true
    }
 
    @IBAction func regenerate(sender: AnyObject!) {
        
    }
    
    @IBAction func useResidentialZoneTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Residential)
    }
    
    @IBAction func useCommercialZoneTool(sender: AnyObject!) {
        (sender as? NSButton).foreach(swapSelectedButton)
        mainView.onToolChanged(.Commercial)
    }
    
    private func swapSelectedButton(button: NSButton) {
        selectedButton.map(setButtonAsUnselected)
        setButtonAsSelected(button)
        selectedButton = button
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
}
