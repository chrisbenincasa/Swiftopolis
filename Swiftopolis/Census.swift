//
//  Census.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/8/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

struct CensusConstants {
    static let CENSUS_RATE: Int = 4
}

class Census {
    // Counts
    var poweredZoneCount: Int = 0
	var unpoweredZoneCount: Int = 0
	var roadTotal: Int = 0
	var railTotal: Int = 0
	var firePop: Int = 0
	var residentialZones: Int = 0
	var commercialZones: Int = 0
	var industrialZones: Int = 0
	var residentialPopulation: Int = 0
	var commercialPopulation: Int = 0
	var industrialPopulation: Int = 0
	var hospitalCount: Int = 0
	var churchCount: Int = 0
	var policeCount: Int = 0
	var fireStationCount: Int = 0
	var stadiumCount: Int = 0
	var coalCount: Int = 0
	var nuclearCount: Int = 0
	var seaportCount: Int = 0
    var airportCount: Int = 0
    var totalPopulation: Int = 0
    
    // Averages
    var crimeAverage: Int = 0
    var pollutionAverage: Int = 0
    var landValueAverage: Int = 0
    var trafficAverage: Int = 0
    
    // Ramps?
    var crimeRamp: Int = 0
    var pollutionRamp: Int = 0
}
