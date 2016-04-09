//
//  Engine.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 2/1/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

// The Engine is the main encapsulation around many factors of game state
// However, instead of acting like a singleton, it is to be injected into all
// dependent modules
class Engine {
    
    private let _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
    
    var toolCursor: ToolCursor?
    var currentTool: Tool? {
        didSet {
            onToolChanged()
        }
    }
    
    private(set) var city: City
    
    private(set) var currentMapPoint: CGPoint

    private(set) var toolPreview: ToolPreview?
    
    private var eventListeners: [EngineEventListener] = []
    
    convenience init() {
        self.init(city: City())
    }
    
    init(city: City) {
        self.city = city
        self.currentMapPoint = CGPoint(x: self.city.map.width / 2, y: self.city.map.height / 2)
    }
    
    // TODO: make this super safe
    func setCurrentMapPoint(point: CGPoint) {
        self.currentMapPoint = point
        dispatch_async(dispatch_get_main_queue()) {
            self.onMapCenterChanged()
        }
    }
    
    func setToolPreview(preview: ToolPreview?) {
        self.toolPreview = preview
    }
    
    func startTimers() {
        let cityAnimDelay = UInt64((Double(city.speed.delay) / 1000.0) * Double(NSEC_PER_SEC))
        let other = UInt64(0.25 * Double(NSEC_PER_SEC))
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, cityAnimDelay, other)
        dispatch_source_set_event_handler(_timer) {
            for listener in self.eventListeners {
                listener.timerFired?()
            }
        }
        
        // Start the timer
        dispatch_resume(_timer)
    }
    
    func stopTimers() {
        dispatch_source_cancel(_timer)
    }
    
    func registerListener(listener: EngineEventListener) {
        self.eventListeners.append(listener)
    }
    
    func onMapCenterChanged() {
        for listener in eventListeners {
            listener.mapCenterChanged?()
        }
    }
    
    func onToolChanged() {
        var dict: [NSObject : AnyObject] = [:]
        if let tool = currentTool {
            dict["tool"] = NSString(UTF8String: tool.rawValue)
        }
        
        for listener in eventListeners {
            listener.toolChanged?(dict)
        }
    }
    
    // Utility Functions
    
    // NOTE: origin is bottom left
    func mapRectForViewport(viewportSize: CGSize) -> CGRect {
        let bottomLeft = CGPoint(x: currentMapPoint.x - (viewportSize.width / 2), y: currentMapPoint.y + (viewportSize.height / 2))
        
        return CGRect(origin: bottomLeft, size: viewportSize)
    }
}

@objc
protocol EngineEventListener {
    optional func timerFired() -> Void
    
    optional func mapCenterChanged() -> Void
    
    optional func toolChanged(data: [NSObject : AnyObject]) -> Void
}