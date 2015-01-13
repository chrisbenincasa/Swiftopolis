//
//  Demand.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/7/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class Demand {
    private(set) var residentialDemand: Int = 0
    private(set) var commercialDemand: Int = 0
    private(set) var industrialDemand: Int = 0
    
    private(set) var needHospital: Int = 0
    private(set) var needChurch: Int = 0
    
    private(set) var stadiumDemand: Bool = false
    private(set) var airportDemand: Bool = false
    private(set) var seaportDemand: Bool = false
    
    func setHospitalDemand(demand: Int) {
        if demand >= -1 || demand <= 1 {
            needHospital = demand
        }
    }
    
    func setChurchDemand(demand: Int) {
        if demand >= -1 || demand <= 1 {
            needChurch = demand
        }
    }
}
