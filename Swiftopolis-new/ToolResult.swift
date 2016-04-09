//
//  ToolResult.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

enum ToolResult {
    case Success
    case None
    case InvalidPosition
    case InsufficientFunds
    
    func toString() -> String {
        switch self {
        case .Success: return "success"
        case .None: return "error"
        case .InvalidPosition: return "invalid position"
        case .InsufficientFunds: return "insufficient funds"
        }
    }
}
