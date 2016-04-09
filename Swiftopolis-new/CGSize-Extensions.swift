//
//  CGSize-Extensions.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 2/26/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

func -(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width - right, height: left.height - right)
}

func -(left: CGSize, right: Int) -> CGSize {
    return left - CGFloat(right)
}

func *(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}

func *(left: CGSize, right: Int) -> CGSize {
    return left * CGFloat(right)
}

func /(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width / right, height: left.height / right)
}

func /(left: CGSize, right: Int) -> CGSize {
    return left / CGFloat(right)
}
