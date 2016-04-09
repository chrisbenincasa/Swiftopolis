//
//  Speed.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/2/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class Speed {
    var delay: Int
    var steps: Int
    
    init(delay: Int, steps: Int) {
        self.delay = delay
        self.steps = steps
    }
}

class PausedSpeed: Speed {
    init() { super.init(delay: 999, steps: 0) }
}

class SlowSpeed: Speed {
    init() { super.init(delay: 625, steps: 1) }
}

class NormalSpeed: Speed {
    init() { super.init(delay: 125, steps: 1) }
}

class FastSpeed: Speed {
    init() { super.init(delay: 25, steps: 1) }
}

class ExtremeSpeed: Speed {
    init() { super.init(delay: 25, steps: 5) }
}