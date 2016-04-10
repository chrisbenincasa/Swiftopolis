//
//  DebugOverlay.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/14/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa
import SpriteKit

class NaturalNumbersGenerator: GeneratorType {
    let start: Int
    let inc: Int
    let end: Int?
    var curr: Int
    
    init(start: Int, inc: Int = 1, end: Int? = nil) {
        self.start = start
        self.inc = inc
        self.end = end
        self.curr = start - 1 // Next increment will be "start"
    }
    
    func next() -> Int? {
        if let x = end {
            guard curr < x else {
                return nil
            }
        }
        
        curr += inc
        return curr
    }
}

struct NaturalNumbers : SequenceType {
    let initialValue: Int = 0
    let increment: Int = 1
    let end: Int?
    
    init(end: Int? = nil) {
        self.end = end
    }
    
    func generate() -> NaturalNumbersGenerator {
        return NaturalNumbersGenerator(start: initialValue, inc: increment, end: self.end)
    }
}

class DebugOverlay: SKNode {
    
    override init() {
        super.init()
        
        self.position = CGPoint.zero
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildGrid(step: Int) {
        for (x, _) in Zip2Sequence(0..<705, NaturalNumbers()) {
            let path = CGPathCreateMutable()
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
        
        for (y, _) in Zip2Sequence(0..<705, NaturalNumbers()) {
            let path = CGPathCreateMutable()
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
