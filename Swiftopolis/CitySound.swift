//
//  CitySound.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/12/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class CitySound {
    private(set) var soundName: String

    internal init(soundName: String) {
        self.soundName = soundName
    }
}

class EarthquakeSound : CitySound {
    convenience init() {
        self.init(soundName: "earthquake.wav")
    }
}
