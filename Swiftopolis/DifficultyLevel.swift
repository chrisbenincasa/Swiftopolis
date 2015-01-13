//
//  DifficultyLevel.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/13/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

enum DifficultyLevel: Int {
    case Easy = 0, Medium = 1, Hard = 2
    
    static func disasterProbForDifficulty(difficulty: DifficultyLevel) -> Int {
        switch difficulty {
        case .Easy: return 480
        case .Medium: return 240
        case .Hard: return 60
        default: return 0
        }
    }
}
