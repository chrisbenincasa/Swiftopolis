//
//  DemandIndicator.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 3/14/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import SpriteKit

class DemandIndicator : SKSpriteNode, Subscriber {
    private var residentialBar: ResizeableRectNode
    private var commercialBar: ResizeableRectNode
    private var industrialBar: ResizeableRectNode
    
    private let UPPER_EDGE = 28
    private let LOWER_EDGE = 20
    private let MAX_LENGTH = 16
    private let RES_LEFT = 8
    private let COM_LEFT = 17
    private let IND_LEFT = 26
    private let BAR_WIDTH = 6
    
    override init(texture: SKTexture!, color: NSColor!, size: CGSize) {
        residentialBar = ResizeableRectNode(size: CGSize(width: BAR_WIDTH, height: 0))
        commercialBar = ResizeableRectNode(size: CGSize(width: BAR_WIDTH, height: 0))
        industrialBar = ResizeableRectNode(size: CGSize(width: BAR_WIDTH, height: 0))
        
        residentialBar.fillColor = NSColor.greenColor()
        commercialBar.fillColor = NSColor.blueColor()
        industrialBar.fillColor = NSColor.yellowColor()
        residentialBar.strokeColor = NSColor.blackColor()
        commercialBar.strokeColor = NSColor.blackColor()
        industrialBar.strokeColor = NSColor.blackColor()
        
        super.init(texture: texture, color: color, size: size)
        anchorPoint = CGPoint.zeroPoint
        
        addChild(residentialBar)
        addChild(commercialBar)
        addChild(industrialBar)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateBars(resDemand: Int, comDemand: Int, indDemand: Int) {
        updateBar(&residentialBar, demand: resDemand, color: NSColor.greenColor(), offsetLeft: RES_LEFT)
        updateBar(&commercialBar, demand: comDemand, color: NSColor.blueColor(), offsetLeft: COM_LEFT)
        updateBar(&industrialBar, demand: indDemand, color: NSColor.yellowColor(), offsetLeft: IND_LEFT)
    }
    
    func demandChanged(data: [NSObject : AnyObject]) {
        let res = data["res"] as? Int
        let com = data["com"] as? Int
        let ind = data["ind"] as? Int
        
        if res != nil && com != nil && ind != nil {
//            println("-- Demand changed...updating DemandIndicator (res \(res!), com \(com!), ind \(ind!)) --")
            
            updateBars(res!, comDemand: com!, indDemand: ind!)
        }
    }
    
    private func updateBar(inout barRef: ResizeableRectNode, demand: Int, color: NSColor, offsetLeft: Int) {
        let ry0 = demand <= 0 ? LOWER_EDGE : UPPER_EDGE
        var ry1 = ry0 - demand / 100
        
        if ry1 - ry0 > MAX_LENGTH {
            ry1 = ry0 + MAX_LENGTH
        } else if ry1 - ry0 < -MAX_LENGTH {
            ry1 = ry0 - MAX_LENGTH
        }
        
        if ry0 != ry1 {
            let resRect = CGRect(x: 0, y: 0, width: BAR_WIDTH, height: abs(ry1 - ry0))
            let oldHeight = barRef.size.height
            let newHeight = CGFloat(abs(ry1 - ry0))
//            barRef.size = CGSize(width: BAR_WIDTH, height: abs(ry1 - ry0))
//            let factor = Int(barRef.size.height) > abs(ry1 - ry0) ? -1 : 1
            
            let action = SKAction.customActionWithDuration(0.5, actionBlock: { (node, elapsed) -> Void in
                let newVal = oldHeight + (elapsed/0.5) * (newHeight - oldHeight)
                barRef.size = CGSize(width: barRef.size.width, height: newVal)
            })
            barRef.runAction(action)
            
            barRef.zPosition = 1
            barRef.position = CGPoint(x: offsetLeft, y: max(ry0, ry1))
            barRef.fillColor = color
        }
    }
}

class ResizeableRectNode : SKShapeNode {
    var size: CGSize {
        didSet {
            self.path = ResizeableRectNode.path(self.size)
        }
    }
    
    init(size: CGSize) {
        self.size = size
        super.init()
        self.path = ResizeableRectNode.path(self.size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func path(size: CGSize) -> CGMutablePathRef {
        var path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRect(origin: CGPoint.zeroPoint, size: size))
        return path
    }
}
