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
    
    private(set) var city: City
    
    private(set) var currentMapPoint: CGPoint
    
    private(set) var toolPreview: ToolPreview?
    
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
    }
    
    func setToolPreview(preview: ToolPreview?) {
        self.toolPreview = preview
    }
}