//
//  TileMapping.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/17/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

class TileMapping {
    var tileName: String
    var ref: TileImage
    var dest: TileImage
    
    init(name: String, ref: TileImage, dest: TileImage) {
        self.tileName = name
        self.ref = ref
        self.dest = dest
    }
}