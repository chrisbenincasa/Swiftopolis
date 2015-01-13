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
    
    func shiftResidential(value: Int? = nil, atIndex: Int = 0) {
        shiftArray(&self.residential, value: value.getOrElse(0), atIndex: atIndex)
    }
    
    func shiftCommercial(value: Int? = nil, atIndex: Int = 0) {
        shiftArray(&self.commercial, value: value.getOrElse(0), atIndex: atIndex)
    }
    
    func shiftIndustrial(value: Int? = nil, atIndex: Int = 0) {
        shiftArray(&self.industrial, value: value.getOrElse(0), atIndex: atIndex)
    }
    
    func shiftCrime(value: Int? = nil, atIndex: Int = 0) {
        shiftArray(&self.crime, value: value.getOrElse(0), atIndex: atIndex)
    }
    
    func shiftPollution(value: Int? = nil, atIndex: Int = 0) {
        shiftArray(&self.pollution, value: value.getOrElse(0), atIndex: atIndex)
    }
    
    func shiftMoney(value: Int? = nil, atIndex: Int = 0) {
        shiftArray(&self.money, value: value.getOrElse(0), atIndex: atIndex)
    }
    
    func setResidentialMax(max: Int) {
        self.residentialMax = max
    }
    
    func setCommercialMax(max: Int) {
        self.commercialMax = max
    }
    
    func setIndustrialMax(max: Int) {
        self.industrialMax = max
    }
    
    // Inserts value at index i, shifting a[i..length - 2] up by one index and dropping value at a[length - 1]
    // Maintains intiial length of array
    // Example:
    // a = [1, 2, 3], length = 3
    // shiftArray(&a, 0, 0)
    // a = [0, 1, 2], length = 3
    private func shiftArray<T>(inout arr: Array<T>, value: T, atIndex: Int) {
        arr.insert(value, atIndex: atIndex)
        arr.removeAtIndex(arr.count - 1)
    }
}
