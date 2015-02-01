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
    static let FIRE_STATION_MAINTENANCE = 100
    static let POLICE_STATION_MAINTENANCE = 100
    
    static func roadMaintenanceMultiplier(d: DifficultyLevel) -> Double {
        switch d {
        case .Easy: return 0.7
        case .Medium: return 0.9
        case .Hard: return 1.2
        default: return 1.0
        }
    }
    
    static func incomeMultipler(d: DifficultyLevel) -> Double {
        switch d {
        case .Easy: return 1.4
        case .Medium: return 1.2
        case .Hard: return 0.8
        default: return 1.0
        }
    }
}

class Budget {
    var cityTax = 7
    var roadPercent = 1.0
    var policePercent = 1.0
    var firePercent = 1.0
    
    var taxEffect: Int = 7
    var roadEffect: Int = 32
    var fireEffect: Int = 1000
    var policeEffect: Int = 1000
    
    var totalFunds: Int = 50000
    var cashFlow: Int = 0
    
    // Income
    var taxFund = 0
    var roadFundEscrow = 0
    var fireFundEscrow = 0
    var policeFundEscrow = 0
}

struct BudgetNumbers {
    var taxRate: Int = 0, taxIncome: Int = 0, operationExpenses: Int = 0, previousBalance: Int = 0, newBalance: Int = 0
    
    var roadRequest: Int = 0, roadFunded: Int = 0, roadPercent: Double = 0.0
    
    var fireRequest: Int = 0, fireFunded: Int = 0, firePercent: Double = 0.0
    
    var policeRequest: Int = 0, policeFunded: Int = 0, policePercent: Double = 0.0
}

typealias BudgetGenerator = (Int, Int, Int, Int, Int) -> BudgetNumbers