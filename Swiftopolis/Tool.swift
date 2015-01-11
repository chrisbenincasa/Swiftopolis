//
//  Tool.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

enum Tool {
    case Residential
    case Commercial
    case Industrial
    
    func cost() -> Int {
        switch self {
        case .Residential: return 100
        case .Commercial: return 100
        case .Industrial: return 100
        default: return -1
        }
    }
    
    func size() -> Int {
        switch self {
        case .Residential: return 3
        default: return -1
        }
    }
    
    func beginStroke(x: Int, y: Int) -> ToolStroke {
        switch self {
        default: return ToolStroke(tool: self, x: x, y: y)
        }
    }
}
