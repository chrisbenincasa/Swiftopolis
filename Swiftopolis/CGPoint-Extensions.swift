//
//  CGPoint-Extensions.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 2/26/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

infix operator +- {
    associativity left precedence 140
}

func +-(left: CGPoint, right: CGFloat) -> CGPoint {
    let x = left.x + right
    let y = left.y - right
    return CGPoint(x: x, y: y)
}

func +-(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y - right.y)
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x - right, y: left.y - right)
}

func -(left: CGPoint, right: Int) -> CGPoint {
    return left - CGFloat(right)
}

func -(left: CGPoint, right: (CGFloat, CGFloat)) -> CGPoint {
    return left - CGPoint(x: right.0, y: right.1)
}

func -(left: CGPoint, right: (Int, Int)) -> CGPoint {
    return left - (CGFloat(right.0), CGFloat(right.1))
}

func *(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

func *(left: CGPoint, right: Int) -> CGPoint {
    return left * CGFloat(right)
}

func /(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
}

func /(left: CGPoint, right: Int) -> CGPoint {
    return left / CGFloat(right)
}
