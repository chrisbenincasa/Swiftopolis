//
//  Subscriber.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/31/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

/*
 Subscribes to notifications in the Micropolis city
*/
@objc
protocol Subscriber {
    
    optional func cityMessage(data: [NSObject: AnyObject]) -> Void
    
    optional func censusChanged(data: [NSObject: AnyObject]) -> Void
    
    optional func demandChanged(data: [NSObject: AnyObject]) -> Void
    
    optional func evaluationChanged(data: [NSObject: AnyObject]) -> Void
    
    optional func fundsChanged(data: [NSObject: AnyObject]) -> Void
    
    optional func optionsChanged(data: [NSObject: AnyObject]) -> Void
    
    // Earthquake
    optional func earthquakeStarted(data: [NSObject: AnyObject]) -> Void
    
    // Map
    optional func mapAnimation(data: [NSObject: AnyObject]) -> Void
    
    optional func mapOverlayDataChanged(/*** mapState: MapState ***/) -> Void
    
    optional func spriteMoved(/*** sprite: Sprite ***/) -> Void
    
    optional func tileChanged(Int, Int) -> Void
    
    optional func wholeMapChanged(data: [NSObject: AnyObject]) -> Void
}
