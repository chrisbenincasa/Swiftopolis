//
//  MainSceneView.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/25/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa
import SpriteKit

class MainSceneView: SKView {
    var engine: Engine!
    
    private var trackingArea: NSTrackingArea?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer = self.makeBackingLayer()
        self.layer?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}