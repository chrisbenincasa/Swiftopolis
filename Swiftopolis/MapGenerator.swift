//
//  MapGenerator.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/11/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Cocoa

class MapGenerator {
    private var city: City
    private var map: [[UInt16]] = []
    private let createIsland: CreateIsland = .Seldom
    private var width: Int
    private var height: Int
    private var currentX: Int = 0
    private var currentY: Int = 0
    private var currentDir: Int = 0
    private var lastDir: Int = 0
    private var xStart: Int = 0
    private var yStart: Int = 0
    
    init(city: City, width: Int, height: Int) {
        self.city = city
        self.width = width
        self.height = height
        initializeMapArray()
    }
    
    func generateNewCity() -> [[UInt16]] {
        return generateMap()
    }
    
    var treeLevel = -1, curveLevel = -1, lakeLevel = -1
    private func generateMap() -> [[UInt16]] {
        if createIsland == .Seldom {
            if arc4random_uniform(100) < 10 {
                makeIsland()
                return map
            }
        } else if createIsland == .Always {
            // make naked Island
        } else {
            clearMap()
        }
        
        if curveLevel != 0 {
            doRivers()
        }
        
        if lakeLevel != 0 {
            makeLakes()
        }
        
        smoothRiver()
        
        if treeLevel != 0 {
            doTrees()
        }
        
        return map
    }
    
    private func makeIsland() {
        makeNakedIsland()
        smoothRiver()
        doTrees()
    }
    
    private func makeNakedIsland() {
        let ISLAND_RADIUS = 18
        for y in 0...height - 1 {
            for x in 0...width - 1 {
                map[y][x] = TileConstants.RIVER
            }
        }
        
        for y in 5...height - 1 {
            for x in 5...width - 1 {
                map[y][x] = TileConstants.DIRT
            }
        }
        
        for var x = 0; x < width - 5; x += 2 {
            currentX = x
            currentY = minRand(ISLAND_RADIUS + 1)
            BRiverPlop()
            currentY = (height - 10) - minRand(ISLAND_RADIUS + 1)
            BRiverPlop()
            currentY = 0
            SRiverPlop()
            currentY = height - 6
            SRiverPlop()
        }
        
        for var y = 0; y < height - 5; y += 2 {
            currentY = y
            currentX = minRand(ISLAND_RADIUS + 1)
            BRiverPlop()
            currentX = (width - 10) - minRand(ISLAND_RADIUS + 1)
            BRiverPlop()
            currentX = 0
            SRiverPlop()
            currentX = width - 6
            SRiverPlop()
        }
    }
    
    private func getRandomStartPosition() {
        currentX = 40 + Int(arc4random_uniform(UInt32(width - 79)))
        currentY = 33 + Int(arc4random_uniform(UInt32(height - 66)))
        
        xStart = currentX
        yStart = currentY
    }
    
    private let DX = [ -1, 0, 1, 0 ]
    private let DY = [ 0, 1, 0, -1 ]
    private let REdTab: [UInt16] = [
        TileConstants.RIVEDGE + 8, TileConstants.RIVEDGE + 8, TileConstants.RIVEDGE + 12, TileConstants.RIVEDGE + 10,
        TileConstants.RIVEDGE + 0, TileConstants.RIVER,       TileConstants.RIVEDGE + 14, TileConstants.RIVEDGE + 12,
        TileConstants.RIVEDGE + 4, TileConstants.RIVEDGE + 6, TileConstants.RIVER,        TileConstants.RIVEDGE + 8,
        TileConstants.RIVEDGE + 2, TileConstants.RIVEDGE + 4, TileConstants.RIVEDGE + 0,  TileConstants.RIVER
    ]
    private let TEdTab: [UInt16] = [
        0, 0, 0, 34,
        0, 0, 36, 35,
        0, 32, 0, 33,
        30, 31, 29, 37
    ]
    
    private func smoothRiver() {
        for y in 0...map.count - 1 {
            for x in 0...map[y].count - 1 {
                if map[y][x] == TileConstants.REDGE {
                    var bitindex = 0
                    for z in 0...3 {
                        bitindex <<= 1
                        let xtem = x + DX[z], ytem = y + DX[z]
                        if city.withinBounds(x: xtem, y: ytem) &&
                            (map[ytem][xtem] & TileConstants.LOMASK) != TileConstants.DIRT &&
                            (map[ytem][xtem] & TileConstants.LOMASK) != TileConstants.WOODS_LOW &&
                            (map[ytem][xtem] & TileConstants.LOMASK) != TileConstants.WOODS_HIGH {
                            
                                bitindex |= 1
                        }
                    }
                    
                    var temp = REdTab[bitindex & 15]
                    if (temp != TileConstants.RIVER) && arc4random_uniform(2) != 0 {
                        temp++
                    }
                    map[y][x] = temp;
                }
            }
        }
    }
    
    private func smoothTrees() {
        for y in 0...map.count - 1 {
            for x in 0...map[y].count - 1 {
                if TileConstants.isTree(map[y][x]) {
                    var bitindex = 0
                    for z in 0...3 {
                        bitindex <<= 1
                        let xtem = x + DX[z], ytem = y + DX[z]
                        if city.withinBounds(x: xtem, y: ytem) && TileConstants.isTree(map[ytem][xtem]){
                                bitindex |= 1
                        }
                    }
                    
                    var temp = TEdTab[bitindex & 15]
                    if temp != 0 {
                        if temp != TileConstants.WOODS && ((x + y) & 1) != 0 {
                            temp -= 8
                        }
                        
                        map[y][x] = temp
                    } else {
                        map[y][x] = temp
                    }
                }
            }
        }
    }
    
    private func doTrees() {
        let amount = treeLevel < 0 ? Int(arc4random_uniform(101)) + 50 : treeLevel + 3
        
        for x in 0...amount - 1 {
            let xPos = Int(arc4random_uniform(UInt32(width))), yPos = Int(arc4random_uniform(UInt32(height)))
            treeSplash(x: xPos, y: yPos)
        }
        
        smoothTrees()
        smoothTrees()
    }
    
    private func treeSplash(#x: Int, y: Int) {
        let dis = treeLevel < 0 ? Int(arc4random_uniform(151) + 50) : Int(arc4random_uniform(101 + (treeLevel * 2)) + 50)
        
        currentX = x
        currentY = y
        
        for z in 0...dis - 1 {
            let dir = Int(arc4random_uniform(8))
            moveMap(dir)
            
            if !city.withinBounds(x: currentX, y: currentY) {
                return
            }
            
            if (map[currentY][currentX] & TileConstants.LOMASK) == TileConstants.DIRT {
                map[currentY][currentX] = TileConstants.WOODS;
            }
        }
    }
    
    private func makeLakes() {
        let lim1 = lakeLevel < 0 ? Int(arc4random_uniform(11) + 1) : lakeLevel / 2
        for t in 0...lim1 - 1 {
            let x = Int(arc4random_uniform(UInt32(width - 20)) + 10)
            let y = Int(arc4random_uniform(UInt32(height - 19)) + 10)
            let lim2 = arc4random_uniform(13) + 2
            
            for z in 0...lim2 - 1 {
                currentX = x - 6 + Int(arc4random_uniform(13))
                currentY = y - 6 + Int(arc4random_uniform(13))
                
                if arc4random_uniform(5) != 0 {
                    SRiverPlop()
                } else {
                    BRiverPlop()
                }
            }
        }
    }
    
    private func doRivers() {
        currentDir = Int(arc4random_uniform(4))
        lastDir = currentDir
        doBRiver()
        
        currentX = xStart
        currentY = yStart
        
        currentDir = lastDir ^ 4
        lastDir = currentDir
        doBRiver()
        
        currentX = xStart
        currentY = yStart
        lastDir = Int(arc4random_uniform(4))
        
        doSRiver()
    }
    
    private func doBRiver() {
        var r1 = 0, r2 = 0
        if curveLevel < 0 {
            r1 = 100
            r2 = 200
        } else {
            r1 = curveLevel + 10
            r2 = curveLevel + 100
        }
        
        while city.withinBounds(x: currentX + 4, y: currentY + 4) {
            BRiverPlop()
            
            if arc4random_uniform(r1 + 1) < 10 {
                currentDir = lastDir
            } else {
                if arc4random_uniform(r2 + 1) > 90 {
                    currentDir++
                }
                if arc4random_uniform(r2 + 1) > 90 {
                    currentDir--
                }
            }
            
            moveMap(currentDir)
        }
    }
    
    private func doSRiver() {
        var r1 = 0, r2 = 0
        if curveLevel < 0 {
            r1 = 100
            r2 = 200
        } else {
            r1 = curveLevel + 10
            r2 = curveLevel + 100
        }
        
        while city.withinBounds(x: currentX + 3, y: currentY + 3) {
            SRiverPlop()
            
            if arc4random_uniform(r1 + 1) < 10 {
                currentDir = lastDir
            } else {
                if arc4random_uniform(r2 + 1) > 90 {
                    currentDir++
                }
                if arc4random_uniform(r2 + 1) > 90 {
                    currentDir--
                }
            }
            
            moveMap(currentDir)
        }
    }
    
    private func clearMap() {
        for i in 0...map.count - 1 {
            for j in 0...map[i].count - 1 {
                map[i][j] = TileConstants.DIRT
            }
        }
    }
    
    private func initializeMapArray() {
        for _ in 0...height - 1 {
            map.append([UInt16](count: width, repeatedValue: 0))
        }
    }
    
    private let BRMatrix: [[UInt16]] = [
        [ 0, 0, 0, 3, 3, 3, 0, 0, 0 ],
        [ 0, 0, 3, 2, 2, 2, 3, 0, 0 ],
        [ 0, 3, 2, 2, 2, 2, 2, 3, 0 ],
        [ 3, 2, 2, 2, 2, 2, 2, 2, 3 ],
        [ 3, 2, 2, 2, 4, 2, 2, 2, 3 ],
        [ 3, 2, 2, 2, 2, 2, 2, 2, 3 ],
        [ 0, 3, 2, 2, 2, 2, 2, 3, 0 ],
        [ 0, 0, 3, 2, 2, 2, 3, 0, 0 ],
        [ 0, 0, 0, 3, 3, 3, 0, 0, 0 ]
    ]
    
    private let SRMatrix: [[UInt16]] = [
        [ 0, 0, 3, 3, 0, 0 ],
        [ 0, 3, 2, 2, 3, 0 ],
        [ 3, 2, 2, 2, 2, 3 ],
        [ 3, 2, 2, 2, 2, 3 ],
        [ 0, 3, 2, 2, 3, 0 ],
        [ 0, 0, 3, 3, 0, 0 ]
    ]
    
    private func BRiverPlop() {
        for x in 0...8 {
            for y in 0...8 {
                putOnMap(BRMatrix[y][x], xOffset: x, yOffset: y)
            }
        }
    }
    
    private func SRiverPlop() {
        for x in 0...5 {
            for y in 0...5 {
                putOnMap(SRMatrix[y][x], xOffset: x, yOffset: y)
            }
        }
    }
    
    private func putOnMap(tile: UInt16, xOffset: Int, yOffset: Int) {
        if tile == 0 {
            return
        }
        
        let x = currentX + xOffset, y = currentY + yOffset
        
        if !city.withinBounds(x: x, y: y) {
            return
        }
        
        var t = map[y][x]
        if t != TileConstants.DIRT {
            t &= TileConstants.LOMASK
            if t == TileConstants.RIVER && tile != TileConstants.CHANNEL {
                return
            }
            
            if t == TileConstants.CHANNEL {
                return
            }
        }
        
        map[y][x] = tile
    }
    
    private let DIRECTION_TABX = [  0,  1,  1,  1,  0, -1, -1, -1 ]
    private let DIRECTION_TABY = [ -1, -1,  0,  1,  1,  1,  0, -1 ]
    
    private func moveMap(var dir: Int) {
        dir &= 7
        currentX += DIRECTION_TABX[dir]
        currentY += DIRECTION_TABY[dir]
    }
    
    private func minRand(limit: UInt32) -> Int {
        return min(
            Int(arc4random_uniform(limit)),
            Int(arc4random_uniform(limit))
        )
    }
}

enum CreateIsland: Double {
    case Never = 0, Seldom = 0.1, Always = 1.0
}
