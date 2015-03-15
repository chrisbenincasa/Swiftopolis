//
//  CityDateNode.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 3/14/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import SpriteKit

class CityDateNode : SKLabelNode {
    private let formatter = NSDateFormatter()
    private let calendar = NSCalendar.currentCalendar()
    private var currentTime: Int = 0
    
    init(initialCityTime: Int) {
        super.init()
        fontSize = 18
        fontName = "Helvetica"
        fontColor = NSColor.blackColor()
        verticalAlignmentMode = .Bottom
        horizontalAlignmentMode = .Right
        formatter.dateFormat = "MMM yyyy"
        let components = NSDateComponents()
        currentTime = initialCityTime
        text = getDateString()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateText(cityTime: Int) {
        self.currentTime = cityTime
        text = getDateString()
    }
    
    private func getDateString() -> String {
        let components = NSDateComponents()
        components.year = 1900 + currentTime / 48
        components.month = (currentTime % 48) / 4
        components.day = (currentTime % 4) * 7 + 1
        
        return formatter.stringFromDate(calendar.dateFromComponents(components)!)
    }
}