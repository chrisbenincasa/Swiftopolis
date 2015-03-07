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
    var map: MapView!
    
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
    
    override func mouseEntered(theEvent: NSEvent) {
        println("mouse entered")
        NSCursor.hide()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        NSCursor.unhide()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        for subview in subviews as [NSView] {
//            subview.needsDisplay = true
//            subview.needsToDrawRect(subview.frame)
        }
    }
    
    // MARK: MapView API
    
    func mapNeedsDisplay() {
        map.needsDisplay = true
    }
    
    func needsToDrawMapRect(dirtyRect: NSRect) {
        map.setNeedsDisplayInRect(dirtyRect)
    }
    
    func doBlink() {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.map.doBlink()
        }
    }
    
    func animateTiles() {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.map.animateTiles()
        }
    }
    
    // MARK: Scene events
    
    // Dispatch event to scene
    func onToolChanged(newTool: Tool) {
        if let s = self.scene as? GameScene {
            s.setCurrentTool(newTool)
        }
    }
    
    func getViewport() -> NSRect {
        return map.getViewport()
    }
    
    override func updateTrackingAreas() {
        //        if self.trackingArea != nil {
        //            self.removeTrackingArea(self.trackingArea!)
        //        }
        //
        //        let opts = NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.ActiveInActiveApp
        //        let trackingArea = NSTrackingArea(rect: self.bounds, options: opts, owner: self, userInfo: nil)
        //        self.addTrackingArea(trackingArea)
        //        self.trackingArea = trackingArea
    }
}