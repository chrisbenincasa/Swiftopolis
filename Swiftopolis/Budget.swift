//
//  Budget.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/2/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

struct BudgetConstants {
    static let TAX_FREQUENCY = 48
}

class Budget {
    var taxEffect: Int = 7
    var roadEffect: Int = 32
    var fireEffect: Int = 1000
    var policeEffect: Int = 1000
    
    var totalFunds: Int = 0
}
