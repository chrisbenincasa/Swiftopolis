//
//  DebugOverlay.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/14/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa
import SpriteKit

class DebugOverlay: SKNode {
    
    override init() {
        super.init()
        
        self.position = CGPoint.zeroPoint
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildGrid(step: Int) {
        for var x = 0, y = 0; x <= 704; x += step, y++ {
            var path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, CGFloat(x), 0)
            CGPathAddLineToPoint(path, nil, CGFloat(x), 704)
            let node = SKShapeNode(path: path)
            if x == 0 {
                node.strokeColor = NSColor.greenColor()
            } else if x % 5 == 0 {
                node.strokeColor = NSColor.redColor()
            } else {
                node.strokeColor = NSColor.blackColor()
            }
            
            self.addChild(node)
        }
        
        for var y = 0, x = 0; y <= 704; y += step, x++ {
            var path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, 0, CGFloat(y))
            CGPathAddLineToPoint(path, nil, 704, CGFloat(y))
            let node = SKShapeNode(path: path)
            
            if y == 0 {
                node.strokeColor = NSColor.greenColor()
            } else if y % 5 == 0 {
                node.strokeColor = NSColor.redColor()
            } else {
                node.strokeColor = NSColor.blackColor()
            }
            
            self.addChild(node)
        }
    }
    
    func attachToNode(node: SKNode) {
        node.addChild(self)
    }
}
