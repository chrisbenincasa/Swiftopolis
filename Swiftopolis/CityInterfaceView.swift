//
//  CityInterfaceView.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/20/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable class CityInterfaceView : NSView {
    
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var gameController: GameViewController!
    @IBOutlet weak var regenerateMapButton: NSButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        println("initing with frame!!")
    }
    
    override func awakeFromNib() {
        println("awoke from NIB")
        let button = NSButton(frame: CGRect(x: 10, y: 0, width: 100, height: 20))
        button.setButtonType(.MomentaryPushInButton)
        button.bezelStyle = .RoundedBezelStyle
        button.title = "Next Map"
        button.target = self.gameController
        button.action = Selector("regenerate:")
        self.regenerateMapButton = button
        self.addSubview(regenerateMapButton)
    }
}