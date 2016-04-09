//
//  AppDelegate.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/27/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//


import Cocoa
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var gameViewController: GameViewController!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
//        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
//            self.skView!.allowsTransparency = true
//            
//            /* Set the scale mode to scale to fit the window */
//            scene.scaleMode = .ResizeFill
//            
//            self.skView!.presentScene(scene)
//            
//            /* Sprite Kit applies additional optimizations to improve rendering performance */
//            self.skView!.ignoresSiblingOrder = true
//            
//            self.skView!.asynchronous = true
//            
//            window.acceptsMouseMovedEvents = true
//            window.makeFirstResponder(self.skView.scene)
//        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
