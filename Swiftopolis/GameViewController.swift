//
//  GameViewController.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/20/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class GameViewController: NSViewController {
    @IBOutlet weak var mapView: MapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    @IBAction func regenerate(sender: AnyObject!) {
        
    }
    
    @IBAction func useResidentialZoneTool(sender: AnyObject!) {
        mapView.onToolChanged(.Residential)
    }
    
    @IBAction func useCommercialZoneTool(sender: AnyObject!) {
        mapView.onToolChanged(.Commercial)
    }
}
