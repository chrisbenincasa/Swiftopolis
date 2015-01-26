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
    var map: MapView!
    var smallMap: OverlayMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("generating map: \(city.map.width)x\(city.map.height)")
        let cityMap = MapGenerator(city: city, width: city.map.width, height: city.map.height).generateNewCity()
        city.setCityMap(cityMap)
        
        // TODO: factor out view construction
        var baseFrame = mainView.frame
        baseFrame.origin = CGPoint(x: 0, y: 0)
        map = MapView(tileSize: 16, frame: baseFrame)
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

        smallMap = OverlayMapView(city: city, frame: NSRect(origin: CGPoint(x: 0, y: Int(view.bounds.size.height) - 320 - 90), size: CGSize(width: 320, height: 320)))
        view.addSubview(smallMap)
        smallMap.needsDisplay = true
    }
 
    @IBAction func regenerate(sender: AnyObject!) {
        
    }
    
    @IBAction func useResidentialZoneTool(sender: AnyObject!) {
//        mapView.onToolChanged(.Residential)
    }
    
    @IBAction func useCommercialZoneTool(sender: AnyObject!) {
//        mapView.onToolChanged(.Commercial)
    }
}
