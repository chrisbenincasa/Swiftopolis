//
//  CitySound.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/12/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class Sound {
    var filename: String!
    var filetype = "wav"
    
    init(_ filename: String) {
        self.filename = filename
    }
    
    func getSoundFilename() -> String {
        return "\(self.filename).\(self.filetype)"
    }
}

class CitySound {
    private(set) var x: Int
    private(set) var y: Int
    private(set) var sound: Sound
    
    init(x: Int, _ y: Int, sound: Sound) {
        self.x = x
        self.y = y
        self.sound = sound
    }
}

class ExplosionSound: Sound {
    private(set) var isHigh: Bool = false
    private(set) var isBoth: Bool = false
    
    init(isHigh: Bool = false, isBoth: Bool = false) {
        if isHigh {
            super.init("explosion-high")
        } else {
            super.init("explosion-low")
        }
        
        self.isHigh = isHigh
        self.isBoth = isBoth
    }
}

class BuildSound: Sound {
    convenience init() {
        self.init("layzone")
    }
}
