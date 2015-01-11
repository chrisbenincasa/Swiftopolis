//
//  ToolStroke.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

class ToolStroke {

    var xSrc: Int
    var ySrc: Int
    var xDest: Int
    var yDest: Int
    var tool: Tool
    
    init(tool: Tool, x: Int, y: Int) {
        self.tool = tool
        self.xSrc = x
        self.xDest = x
        self.ySrc = y
        self.yDest = y
    }
    
    func apply() -> ToolResult {
        return .None
    }
    
    func applyArea() {
        let toolSize = tool.size()
        let bounds = getBounds()
        
        for var i = 0; i < Int(bounds.height); i += toolSize {
            for var j = 0; j < Int(bounds.width); j += toolSize {
                self.apply()
            }
        }
    }
    
    func getBounds() -> CGRect {
        let toolSize = tool.size()
        var x: Int = self.xSrc, y: Int = self.ySrc, width: Int, height: Int
        
        if toolSize >= 3 {
            x -= 1
        }
        
        width = (self.xDest - self.xSrc / (toolSize + 1)) * toolSize
        
        if self.xDest < self.xSrc {
            x += toolSize - width
        }
        
        if toolSize >= 3 {
            y -= 1
        }
        
        height = (self.yDest - self.ySrc / (toolSize + 1)) * toolSize
        
        if self.yDest < self.ySrc {
            y += toolSize - height
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func applyInner(t: Tool) -> Bool {
        switch tool {
        default: return false
        }
    }
}
