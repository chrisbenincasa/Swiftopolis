//
//  CityProblem.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/3/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

enum CityProblem: Int {
    case Crime, Pollution, Housing, Taxes, Traffic, Unemployment, Fire
    
    static func getAllProblems() -> [CityProblem] {
        var c = 0
        var problem: CityProblem? = CityProblem(rawValue: c)
        var problems: [CityProblem] = []
        while (problem != nil) {
            problems.append(problem!)
            c += 1
            problem = CityProblem(rawValue: c)
        }
        
        return problems
    }
}
