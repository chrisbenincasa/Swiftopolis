//
//  PointUtils.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 3/11/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

class PointUtils {
    class func topLeftMapPoint(center: CGPoint, viewport: CGSize) -> CGPoint {
        let halfViewportSizeInTiles = Int(viewport.width) >> 1
        return center - halfViewportSizeInTiles
    }
    
    class func normalizeMapPoint(var point: CGPoint, bounds: NSSize, viewport: NSSize = NSSize.zeroSize) -> CGPoint {
        let halfViewportWidth = Int(viewport.width) >> 1   // Ints round down
        let halfViewportHeight = Int(viewport.height) >> 1 // Ints round down
        let halfWidth = Int(bounds.width) >> 1
        let halfHeight = Int(bounds.height) >> 1
        
        if Int(point.x) - halfViewportWidth < 0 {
            point.x = CGFloat(halfViewportWidth)
        } else if Int(point.x) + halfViewportWidth > Int(bounds.width) {
            point.x = bounds.width - CGFloat(halfViewportWidth)
        }
        
        if Int(point.y) - halfViewportHeight < 0 {
            point.y = CGFloat(halfViewportHeight)
        } else if Int(point.y) + halfViewportHeight > Int(bounds.height) {
            point.y = bounds.height - CGFloat(halfViewportHeight)
        }
        
        return point
    }
}