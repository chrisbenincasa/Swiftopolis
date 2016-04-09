//
//  ToolNode.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 3/11/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import SpriteKit

class ToolNode: SKShapeNode {
    init(size _size: CGSize, tileSize _tileSize: Int, toolCursor _toolCursor: ToolCursor) {
        super.init()
        let shapeRect = NSRect(origin: CGPoint.zero, size: _size * _tileSize)
        let mutablePath = CGPathCreateMutable()
        CGPathAddRect(mutablePath, nil, shapeRect)
        path = mutablePath
        SKShapeNode(rect: shapeRect)
        fillColor = _toolCursor.fillColor
        lineWidth = 2.0
        glowWidth = 0.5
        zPosition = 1.0
        strokeColor = _toolCursor.borderColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}