//
//  GameViewController.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/20/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class GameViewController: NSViewController {

    @IBOutlet weak var userInterface: CityInterfaceView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(userInterface)
//        NSBundle.mainBundle().loadNibNamed("CityInterfaceView", owner: self, topLevelObjects: nil)
    }
 
    @IBAction func regenerate(sender: AnyObject!) {
        println("regen!")
    }
}
