//
//  main.swift
//  TileGenerator
//
//  Created by Christian Benincasa on 1/17/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

var tileSize: Int = 0
var inputFile: String?
var outputDir: String?

for arg in Process.arguments {
    println("arg: \(arg)")
}

for var i = 1; i < Int(C_ARGC); i++ {
    let index = Int(i)
    let next = Int(i + 1)
    
    let arg = String.fromCString(C_ARGV[index])!
    switch arg {
        case "--tile-size":
            tileSize = String.fromCString(C_ARGV[next])!.toInt()!
            i++
            break;
        case "--input-file":
            inputFile = String.fromCString(C_ARGV[next])
            i++
            break;
        case "--output-dir":
            outputDir = String.fromCString(C_ARGV[next])
            i++
            break
        default: break
    }
}

println("generating with tile size of \(tileSize)")

//assert(inputFile != nil, "You must specify an input file!")

println("reading from input file \(inputFile) and writing to output directory \(outputDir)")

if let data: NSData = NSFileManager.defaultManager().contentsAtPath(inputFile!) {
    let json = JSON(data: data)
    let reader = TileReader(_json: json)
    
    let manager = NSFileManager.defaultManager()
    let origDir = manager.currentDirectoryPath
    manager.changeCurrentDirectoryPath(manager.currentDirectoryPath + "/graphics")
    reader.process()
    manager.changeCurrentDirectoryPath(origDir)
}


