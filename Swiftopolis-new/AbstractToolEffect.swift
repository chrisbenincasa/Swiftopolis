//
//  AbstractToolEffect.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

protocol AbstractToolEffect {
    func getTile(dx: Int, _ dy: Int) -> UInt16
    func setTile(dx: Int, _ dy: Int, _ tile: UInt16)
    func makeSound(dx: Int, _ dy: Int, sound: Sound)
    func spend(amount: Int)
}

class OffsetToolEffect: AbstractToolEffect, CustomStringConvertible {
    // Printable
    var name = "OffsetToolEffect"
    var description: String {
        return "\(name)(\(dx), \(dy))"
    }
    
    private(set) var base: AbstractToolEffect
    private(set) var dx: Int
    private(set) var dy: Int
    
    init(base: AbstractToolEffect, dx: Int, dy: Int) {
        self.base = base
        self.dx = dx
        self.dy = dy
    }
    
    func getTile(dx: Int, _ dy: Int) -> UInt16 {
        return base.getTile(self.dx + dx, self.dy + dy)
    }
    
    func setTile(dx: Int, _ dy: Int, _ tile: UInt16) {
        base.setTile(self.dx + dx, self.dy + dy, tile)
    }
    
    func makeSound(dx: Int, _ dy: Int, sound: Sound) {
        base.makeSound(self.dx + dx, self.dy + dy, sound: sound)
    }
    
    func spend(amount: Int) {
        base.spend(amount)
    }
}