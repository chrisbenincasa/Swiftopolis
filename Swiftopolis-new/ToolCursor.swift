//
//  ToolCursor.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/22/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import Cocoa

struct ToolCursorColors {
    static let BACKGROUND_OPACITY: CGFloat = 0.375
    static let BROWNISH_COLOR = NSColor(calibratedRed: 191, green: 121, blue: 0, alpha: 1)
    static let GRAYISH_COLOR = NSColor(calibratedRed: 93, green: 93, blue: 93, alpha: 1)
    
    static func colorsForTool(tool: Tool) -> (NSColor, NSColor) {
        switch tool {
        case .Residential:
            let color = NSColor.greenColor()
            return (color.colorWithAlphaComponent(BACKGROUND_OPACITY), color)
        case .Commercial:
            let color = NSColor.blueColor()
            return (color.colorWithAlphaComponent(BACKGROUND_OPACITY), color)
        case .Industrial:
            let color = NSColor.yellowColor()
            return (color.colorWithAlphaComponent(BACKGROUND_OPACITY), color)
        case .Bulldozer:
            return (NSColor.clearColor(), BROWNISH_COLOR)
        case .Wire:
            return (NSColor.blackColor().colorWithAlphaComponent(BACKGROUND_OPACITY), NSColor.yellowColor())
        case .Road:
            return (NSColor.whiteColor().colorWithAlphaComponent(BACKGROUND_OPACITY), GRAYISH_COLOR)
        case .Rail:
            return (NSColor(calibratedRed: 127, green: 127, blue: 0, alpha: 1), GRAYISH_COLOR)
        case .FireStation:
            return (NSColor.greenColor().colorWithAlphaComponent(BACKGROUND_OPACITY), NSColor.redColor())
        case .PoliceStation:
            return (NSColor.greenColor().colorWithAlphaComponent(BACKGROUND_OPACITY), NSColor.blueColor())
        case .Coal, .Nuclear:
            return (GRAYISH_COLOR.colorWithAlphaComponent(BACKGROUND_OPACITY), NSColor.yellowColor())
        case .Stadium:
            return (GRAYISH_COLOR.colorWithAlphaComponent(BACKGROUND_OPACITY), NSColor.greenColor())
        case .Seaport:
            return (GRAYISH_COLOR.colorWithAlphaComponent(BACKGROUND_OPACITY), NSColor.blueColor())
        case .Airport:
            return (GRAYISH_COLOR.colorWithAlphaComponent(BACKGROUND_OPACITY), BROWNISH_COLOR)
        case .Park:
            return (NSColor.greenColor().colorWithAlphaComponent(BACKGROUND_OPACITY), BROWNISH_COLOR)
        default: return (NSColor.clearColor(), NSColor.clearColor())
        }
    }
}

class ToolCursor {
    var rect: NSRect
    var borderColor: NSColor
    var fillColor: NSColor
    
    init(rect: NSRect, borderColor: NSColor, fillColor: NSColor) {
        self.rect = rect
        self.borderColor = borderColor
        self.fillColor = fillColor
    }
    
    convenience init(tool: Tool, withRect rect: NSRect) {
        let (backgroundColor, borderColor) = ToolCursorColors.colorsForTool(tool)
        self.init(rect: rect, borderColor: borderColor, fillColor: backgroundColor)
    }
}
