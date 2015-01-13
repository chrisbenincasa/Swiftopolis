//
//  CityHistory.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/12/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class CityHistory {
    var cityTime: Int = 0
    private(set) var residential: [Int] = []
    private(set) var commercial: [Int] = []
    private(set) var industrial: [Int] = []
    private(set) var money: [Int] = []
    private(set) var crime: [Int] = []
    private(set) var pollution: [Int] = []
    private(set) var residentialMax: Int = 0
    private(set) var commercialMax: Int = 0
    private(set) var industrialMax: Int = 0
    
    init() {
        Utils.initializeArray(&self.residential, size: 240, value: 0)
        Utils.initializeArray(&self.commercial, size: 240, value: 0)
        Utils.initializeArray(&self.industrial, size: 240, value: 0)
        Utils.initializeArray(&self.money, size: 240, value: 0)
        Utils.initializeArray(&self.crime, size: 240, value: 0)
        Utils.initializeArray(&self.pollution, size: 240, value: 0)
    }
    
    func shiftResidential(idx: Int) {
        self.residential.insert(self.residential[idx], atIndex: idx + 1)
    }
}
