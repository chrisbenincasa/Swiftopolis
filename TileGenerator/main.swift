//
//  main.swift
//  TileGenerator
//
//  Created by Christian Benincasa on 1/17/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

let tileSizeDirFmt = "%dx%d"
var tileSize: Int = 0
var inputFile: String?
var outputDir: String?

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
            let dir = String.fromCString(C_ARGV[next])
            outputDir = dir?.stringByReplacingOccurrencesOfString("\n", withString: "", options: .CaseInsensitiveSearch, range: nil)
            i++
            break
        default: break
    }
}

println("generating with tile size of \(tileSize)")

//assert(inputFile != nil, "You must specify an input file!")

println("reading from input file \(inputFile!) and writing to output directory \(outputDir!)")

if let data: NSData = NSFileManager.defaultManager().contentsAtPath(inputFile!) {
    let json = JSON(data: data)
    let reader = TileReader(_json: json)
    
    let manager = NSFileManager.defaultManager()
    let origDir = manager.currentDirectoryPath
    manager.changeCurrentDirectoryPath(manager.currentDirectoryPath + "/graphics")
    let imageData = reader.process()
    manager.changeCurrentDirectoryPath(origDir)
    
    if let data = imageData {
        var isDir = ObjCBool(true)
        var error: NSErrorPointer = nil
        if !manager.fileExistsAtPath(outputDir!, isDirectory: &isDir) {
            manager.createDirectoryAtPath(outputDir!, withIntermediateDirectories: true, attributes: nil, error: error)
        }
        
        manager.changeCurrentDirectoryPath(manager.currentDirectoryPath + "/" + outputDir!)
        
        manager.removeItemAtPath(manager.currentDirectoryPath + "/" + "final.png", error: nil)
        data.writeToFile(manager.currentDirectoryPath + "/" + "final.png", atomically: false)
        manager.changeCurrentDirectoryPath(origDir)
    }
    
    let indexJSON = reader.generateIndexFile()

    manager.changeCurrentDirectoryPath(manager.currentDirectoryPath + "/" + outputDir!)
    indexJSON.rawData(options: NSJSONWritingOptions.allZeros, error: nil)?.writeToFile(manager.currentDirectoryPath + "/tiles_index.json" , atomically: false)
}


