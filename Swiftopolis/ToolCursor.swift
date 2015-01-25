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
    static let RESIDENTIAL_TOOL_COLOR = NSColor.greenColor()
    static let COMMERCIAL_TOOL_COLOR = NSColor.blueColor()
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
    
    class func residentialTool(rect withRect: NSRect = NSRect.zeroRect) -> ToolCursor {
        var background = ToolCursorColors.RESIDENTIAL_TOOL_COLOR.colorWithAlphaComponent(ToolCursorColors.BACKGROUND_OPACITY)
        return ToolCursor(rect: withRect, borderColor: ToolCursorColors.RESIDENTIAL_TOOL_COLOR, fillColor: background)
    }
    
    class func commercialTool(rect withRect: NSRect = NSRect.zeroRect) -> ToolCursor {
        var background = ToolCursorColors.COMMERCIAL_TOOL_COLOR.colorWithAlphaComponent(ToolCursorColors.BACKGROUND_OPACITY)
        return ToolCursor(rect: withRect, borderColor: ToolCursorColors.COMMERCIAL_TOOL_COLOR, fillColor: background)
    }
    
    class func toolCursorForTool(tool: Tool, rect withRect: NSRect = NSRect.zeroRect) -> ToolCursor {
        switch tool {
        case .Residential: return residentialTool(rect: withRect)
        case .Commercial: return commercialTool(rect: withRect)
        default: fatalError("Unrecognized tool type")
        }
    }
}
