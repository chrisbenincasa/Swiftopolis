//
//  CityEvaluation.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/5/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class CityEvaluation {
    var city: City
    var approveCount: Int = 0
    var disapproveCount: Int = 0
    var assessmentvalue: Int = 0
    var score: Int = 500
    var scoreDelta: Int = 0
    var population: Int = 0
    var populationDelta: Int = 0
    var cityClass: CityClass = .Village
    var cityProblems: [CityProblem] = []
    var problemVotes: [CityProblem : Int] = [:]
    var problemScores: [CityProblem : Int] = [:]
    
    init(city: City) {
        self.city = city
    }
    
    func cityEvaluation() {
        if city.census.totalPopulation != 0 {
            calculateAssessment()
            doPopulation()
            doCityProblems()
            calculateScore()
            doVotes()
        }
    }
    
    private func calculateAssessment() {
        var z = 0
        z += city.census.roadTotal * 5
        z += city.census.railTotal * 10
        z += city.census.policeCount * 1000;
        z += city.census.fireStationCount * 1000;
        z += city.census.hospitalCount * 400;
        z += city.census.stadiumCount * 3000;
        z += city.census.seaportCount * 5000;
        z += city.census.airportCount * 10000;
        z += city.census.coalCount * 3000;
        z += city.census.nuclearCount * 6000;
        assessmentvalue = z * 1000;
    }
    
    private func doPopulation() {
        let oldPop = population
        population = city.census.lastPopulation
        populationDelta = population - oldPop
        var classVal = 0
        switch population {
        case 0..<2000:
            classVal = 0
            break
        case 2000..<10000:
            classVal = 1
            break
        case 10000..<50000:
            classVal = 2
            break
        case 50000..<100000:
            classVal = 3
            break
        case 100000..<500000:
            classVal = 4
            break
        default:
            classVal = 5
        }
        cityClass = CityClass(rawValue: classVal)!
    }
    
    private func doCityProblems() {
        problemScores[.Crime] = city.census.crimeAverage
        problemScores[.Pollution] = city.census.pollutionAverage
        problemScores[.Housing] = Int(round(Double(city.census.landValueAverage) * 0.7))
        problemScores[.Taxes] = city.budget.cityTax * 10
        problemScores[.Traffic] = calculateAverageTraffic()
        problemScores[.Unemployment] = calculateUnemployment()
        problemScores[.Fire] = min(255, city.census.firePop * 5)
        
        fillVotes()
        
        var sortedKeys = Array(problemScores.keys).sorted({ [unowned self] in self.problemVotes[$0] >= self.problemVotes[$1] })
        cityProblems.removeAll(keepCapacity: false)
        for i in 0..<4 {
            cityProblems.append(sortedKeys[i])
        }
        
    }
    
    private func calculateAverageTraffic() -> Int {
        var count = 1, total = 0
        
        for var y = 0; y < city.getHeight(); y++ {
            for var x = 0; x < city.getWidth(); x++ {
                if city.map.getLandValueAtLocation(x: x, y: y) != 0 {
                    total += Int(city.map.trafficDensityAtLocation(x: x, y: y))
                    count++
                }
            }
        }
        
        city.census.trafficAverage = Int(round(Double(total) + Double(count) * 2.4))
        return city.census.trafficAverage
    }
    
    private func calculateUnemployment() -> Int {
        var availableJobs = (city.census.commercialPopulation + city.census.industrialPopulation) * 8
        if availableJobs == 0 {
            return 0
        }
        
        var jobs = Double(city.census.residentialPopulation) / Double(availableJobs)
        availableJobs = Int(floor((jobs - 1.0) * 255.0))
        if availableJobs > 255 {
            availableJobs = 255
        }
        
        return availableJobs
    }
    
    private func calculateScore() {
        let oldCityScore = score
        var x = 0
        for v in Array(problemScores.values) {
            x += v
        }
        
        x = min(256, x / 3)
        var z: Double = Double(clamp(value: (256 - x) * 4, minimum: 0, maximum: 1000))
        
        if city.demand.stadiumDemand {
            z = 0.85 * z
        }
        
        if city.demand.airportDemand {
            z = 0.85 * z
        }
        
        if city.demand.seaportDemand {
            z = 0.85 * z
        }
        
        if city.budget.roadEffect < 32 {
            z -= Double(32 - city.budget.roadEffect)
        }
        if city.budget.policeEffect < 1000 {
            z *= 0.9 + (Double(city.budget.policeEffect) / 10000.1)
        }
        
        if city.budget.fireEffect < 1000 {
            z *= 0.9 + (Double(city.budget.fireEffect) / 10000.1)
        }
        
        if city.demand.residentialDemand < -1000 {
            z *= 0.85;
        }
        
        if city.demand.commercialDemand < -1000 {
            z *= 0.85;
        }
        
        if city.demand.industrialDemand < -1000 {
            z *= 0.85
        }
        
        var SM: Double = 1.0
        if (populationDelta > 0) {
            SM = Double(populationDelta) / (Double(population) + 1.0)
        } else if populationDelta < 0 {
            SM = 0.95 + Double(populationDelta) / Double(population - populationDelta)
        }
        
        z *= SM
        z -= Double(min(255, city.census.firePop * 5))
        z -= Double(city.budget.cityTax)
        
        
        let TM = city.census.unpoweredZoneCount + city.census.poweredZoneCount
        SM = TM != 0 ? Double(city.census.poweredZoneCount) / Double(TM) : 1.0
        z *= SM
        
        z = clamp(value: z, minimum: 0.0, maximum: 1000.0)
        
        score = Int(round((Double(score) + z) / 2.0))
        scoreDelta = score - oldCityScore;
    }
    
    // TODO: calculate differently (based on actual approval)
    private func doVotes() {
        approveCount = 0
        disapproveCount = 0
        for i in 0..<100 {
            if Int(arc4random_uniform(1001)) < score {
                approveCount++
            } else {
                disapproveCount++
            }
        }
    }
    
    private func fillVotes() {
        let problems = CityProblem.getAllProblems()
        var votes: [Int] = []
        var totalVotes = 0
        Utils.initializeArray(&votes, size: problems.count, value: 0)
        for i in 0..<600 {
            if Int(arc4random_uniform(301)) < problemScores[problems[i % problems.count]] {
                votes[i % problems.count]++
                totalVotes++
                if totalVotes >= 100 {
                    break
                }
            }
        }
        
        var retMap: [CityProblem : Int] = [:]
        for var i = 0; i < problems.count; i++ {
            retMap[problems[i]] = votes[i]
        }
    
        problemVotes = retMap
    }
    
    private func clamp<T : Comparable>(#value: T, minimum: T, maximum: T) -> T {
        return max(minimum, min(maximum, value))
    }
}

enum CityClass : Int {
    case Village = 0
    case Town = 1
    case City = 2
    case Capital = 3
    case Metropolis = 4
    case Megalopolis = 5
}
