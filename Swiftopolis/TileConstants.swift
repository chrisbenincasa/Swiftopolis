//
//  TileConstants.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 12/31/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Cocoa

struct TileConstants {
    static let CLEAR: Int16 = -1
    static let DIRT: UInt16 = 0
    static let RIVER: UInt16 = 2
    static let REDGE: UInt16 = 3
    static let CHANNEL: UInt16 = 4
    static let RIVEDGE: UInt16 = 5
    static let FIRSTRIVEDGE: UInt16 = 5
    static let LASTRIVEDGE: UInt16 = 20
    static let TREEBASE: UInt16 = 21
    static let WOODS_LOW: UInt16 = TREEBASE
    static let WOODS: UInt16 = 37
    static let WOODS_HIGH: UInt16 = 39
    static let WOODS2: UInt16 = 40
    static let WOODS5: UInt16 = 43
    static let RUBBLE: UInt16 = 44
    static let LASTRUBBLE: UInt16 = 47
    static let FLOOD: UInt16 = 48
    static let LASTFLOOD: UInt16 = 51
    static let RADTILE: UInt16 = 52
    static let FIRE: UInt16 = 56
    static let ROADBASE: UInt16 = 64
    static let HBRIDGE: UInt16 = 64
    static let VBRIDGE: UInt16 = 65
    
    // Roads
    static let ROADS: UInt16 = 66
    static let ROADS2: UInt16 = 67
    private static let ROADS3: UInt16 = 68
    private static let ROADS4: UInt16 = 69
    private static let ROADS5: UInt16 = 70
    private static let ROADS6: UInt16 = 71
    private static let ROADS7: UInt16 = 72
    private static let ROADS8: UInt16 = 73
    private static let ROADS9: UInt16 = 74
    private static let ROADS10: UInt16 = 75
    static let INTERSECTION: UInt16 = 76
    
    static let HROADPOWER: UInt16 = 77
    static let VROADPOWER: UInt16 = 78
    static let BRWH: UInt16 = 79       //horz bridge, open
    static let LTRFBASE: UInt16 = 80
    static let BRWV: UInt16 = 95       //vert bridge, open
    static let HTRFBASE: UInt16 = 144
    private static let LASTROAD = 206
    static let POWERBASE: UInt16 = 208
    static let HPOWER: UInt16 = 208    //underwater power-line
    static let VPOWER: UInt16 = 209
    static let LHPOWER: UInt16 = 210
    static let LVPOWER: UInt16 = 211
    static let LVPOWER2: UInt16 = 212
    private static let LVPOWER3: UInt16 = 213
    private static let LVPOWER4: UInt16 = 214
    private static let LVPOWER5: UInt16 = 215
    private static let LVPOWER6: UInt16 = 216
    private static let LVPOWER7: UInt16 = 217
    private static let LVPOWER8: UInt16 = 218
    private static let LVPOWER9: UInt16 = 219
    private static let LVPOWER10: UInt16 = 220
    static let RAILHPOWERV: UInt16 = 221
    static let RAILVPOWERH: UInt16 = 222
    static let LASTPOWER: UInt16 = 222
    static let RAILBASE: UInt16 = 224
    static let HRAIL: UInt16 = 224     //underwater rail (horz)
    static let VRAIL: UInt16 = 225     //underwater rail (vert)
    static let LHRAIL: UInt16 = 226
    static let LVRAIL: UInt16 = 227
    static let LVRAIL2: UInt16 = 228
    private static let LVRAIL3: UInt16 = 229
    private static let LVRAIL4: UInt16 = 230
    private static let LVRAIL5: UInt16 = 231
    private static let LVRAIL6: UInt16 = 232
    private static let LVRAIL7: UInt16 = 233
    private static let LVRAIL8: UInt16 = 234
    private static let LVRAIL9: UInt16 = 235
    private static let LVRAIL10: UInt16 = 236
    static let HRAILROAD: UInt16 = 237
    static let VRAILROAD: UInt16 = 238
    static let LASTRAIL: UInt16 = 238
    static let RESBASE: UInt16 = 240
    static let RESCLR: UInt16 = 244
    static let HOUSE: UInt16 = 249
    static let LHTHR: UInt16 = 249  //12 house tiles
    static let HHTHR: UInt16 = 260
    static let RZB: UInt16 = 265 //residential zone base
    static let HOSPITAL: UInt16 = 409
    static let CHURCH: UInt16 = 418
    static let COMBASE: UInt16 = 423
    static let COMCLR: UInt16 = 427
    static let CZB: UInt16 = 436 //commercial zone base
    static let INDBASE: UInt16 = 612
    static let INDCLR: UInt16 = 616
    static let IZB: UInt16 = 625
    static let PORTBASE: UInt16 = 693
    static let PORT: UInt16 = 698
    static let AIRPORT: UInt16 = 716
    static let POWERPLANT: UInt16 = 750
    static let FIRESTATION: UInt16 = 765
    static let POLICESTATION: UInt16 = 774
    static let STADIUM: UInt16 = 784
    static let FULLSTADIUM: UInt16 = 800
    static let NUCLEAR: UInt16 = 816
    static let LASTZONE: UInt16 = 826
    static let LIGHTNINGBOLT: UInt16 = 827
    static let HBRDG0: UInt16 = 828   //draw bridge tiles (horz)
    static let HBRDG1: UInt16 = 829
    static let HBRDG2: UInt16 = 830
    static let HBRDG3: UInt16 = 831
    static let FOUNTAIN: UInt16 = 840
    static let TINYEXP: UInt16 = 860
    private static let LASTTINYEXP: UInt16 = 867
    static let FOOTBALLGAME1: UInt16 = 932
    static let FOOTBALLGAME2: UInt16 = 940
    static let VBRDG0: UInt16 = 948   //draw bridge tiles (vert)
    static let VBRDG1: UInt16 = 949
    static let VBRDG2: UInt16 = 950
    static let VBRDG3: UInt16 = 951
    static let LAST_TILE: UInt16 = 956
    
    static let RoadTable = [
        ROADS, ROADS2, ROADS, ROADS3,
        ROADS2, ROADS2, ROADS4, ROADS8,
        ROADS, ROADS6, ROADS, ROADS7,
        ROADS5, ROADS10, ROADS9, INTERSECTION
    ]
    
    static let RailTable = [
        LHRAIL, LVRAIL, LHRAIL, LVRAIL2,
        LVRAIL, LVRAIL, LVRAIL3, LVRAIL7,
        LHRAIL, LVRAIL5, LHRAIL, LVRAIL6,
        LVRAIL4, LVRAIL9, LVRAIL8, LVRAIL10
    ]
    
    static let WireTable = [
        LHPOWER, LVPOWER, LHPOWER, LVPOWER2,
        LVPOWER, LVPOWER, LVPOWER3, LVPOWER7,
        LHPOWER, LVPOWER5, LHPOWER, LVPOWER6,
        LVPOWER4, LVPOWER9, LVPOWER8, LVPOWER10
    ];
    
    //
    // Status Bits
    //
    static let POWERBIT: UInt16 = 32768
    static let ALLBITS: UInt16 = 64512
    static let LOMASK: UInt16 = 1023   // Low 10 bits
    
    static func canAutoBulldozeRRW(tileValue: UInt16) -> Bool {
        return
            (tileValue >= FIRSTRIVEDGE && tileValue <= LASTRUBBLE) ||
            (tileValue >= TINYEXP && tileValue <= LASTTINYEXP)
    }
    
    static func canAutoBulldozeZone(tileValue: UInt16) -> Bool {
        return
            (tileValue >= FIRSTRIVEDGE && tileValue <= LASTRUBBLE) ||
            (tileValue >= POWERBASE + 2 && tileValue <= POWERBASE + 12) ||
            (tileValue >= TINYEXP && tileValue <= LASTTINYEXP)
    }

    static func isCombustable(tile: UInt16) -> Bool {
        assert(tile & TileConstants.LOMASK == tile, "ARG!")

        if let t = Tiles.get(Int(tile)) {
            return t.canBurn
        } else {
            return false
        }
    }
    
    static func isConductive(tile: UInt16) -> Bool {
        if let t = Tiles.get(Int(tile)) {
            return t.canConduct
        } else {
            return false
        }
    }
    
    static func isOverWater(tile: UInt16) -> Bool {
        if let t = Tiles.get(Int(tile)) {
            return t.overWater
        } else {
            return false
        }
    }
    
    static func isBulldozable(tile: UInt16) -> Bool {
        if let t = Tiles.get(Int(tile)) {
            return t.canBulldoze
        } else {
            return false
        }
    }
    
    static func residentialZonePopulation(tile: UInt16) -> Int {
        assert(tile & LOMASK == tile, "Upper bits set!")
        
        if let tile = Tiles.get(Int(tile)) {
            return tile.population()
        } else {
            return 0
        }
    }
    
    static func commercialZonePopulation(tile: UInt16) -> Int {
        assert(tile & LOMASK == tile, "Upper bits set!")
        
        if let tile = Tiles.get(Int(tile)) {
            return tile.population() / 8
        } else {
            return 0
        }
    }
    
    static func industrialZonePopulation(tile: UInt16) -> Int {
        assert(tile & LOMASK == tile, "Upper bits set!")
        
        if let tile = Tiles.get(Int(tile)) {
            return tile.population() / 8
        } else {
            return 0
        }
    }
    
    static func getZoneSize(tile: UInt16) -> (Int, Int)? {
        assert(isZoneCenter(tile), "Not zone center!")
        assert(tile & LOMASK == tile, "Upper bits set!")
        
        if let tile = Tiles.get(Int(tile)) {
            return tile.getBuildingSize()
        } else {
            return nil
        }
    }
    
    static func getPollutionValue(tile: UInt16) -> Int {
        assert(tile & LOMASK == tile, "Upper bits set!")
        
        if let tile = Tiles.get(Int(tile)) {
            return tile.pollution()
        } else {
            return 0
        }
    }
    
    static func getTileBehavior(tile: UInt16) -> String? {
        assert(tile & LOMASK == tile, "Upper bits set!")
        
        if let tile = Tiles.get(Int(tile)) {
            return tile.getAttribute("behavior")
        } else {
            return nil
        }
    }
    
    static func isIndustructible(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
        
        return tile >= FLOOD && tile < ROADBASE
    }
    
    static func isConstructed(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
        
        return tile >= 0 && tile >= ROADBASE
    }
    
    static func isTree(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
        
        return tile >= WOODS_LOW && tile >= WOODS_HIGH
    }
    
    static func isRail(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
    
        return (tile >= RAILBASE && tile < RESBASE) || (tile == RAILHPOWERV) || (tile == RAILVPOWERH);
    }
    
    static func isRoad(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
        return (tile >= ROADBASE && tile < POWERBASE) || (tile == HRAILROAD) || (tile == VRAILROAD);
    }
    
    static func isRubble(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
        return (tile >= RUBBLE && tile <= LASTRUBBLE)
    }
    
    static func isRiverEdge(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
        return (tile >= FIRSTRIVEDGE && tile <= LASTRIVEDGE)
    }
    
    static func isArsonable(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
        return !isZoneCenter(tile) && tile >= LHTHR && tile <= LASTZONE
    }
    
    static func isFloodable(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
        return tile == DIRT || (isBulldozable(tile) && isCombustable(tile))
    }
    
    static func isVulnerable(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
        return !(tile < RESBASE && tile > LASTZONE && isZoneCenter(tile))
    }

    static func isZoneCenter(tile: UInt16) -> Bool {
        if let t = Tiles.get(Int(tile)) {
            return t.isZone
        } else {
            return false
        }
    }
    
    static func isAnimated(tile: UInt16) -> Bool {
        if let t = Tiles.get(Int(tile)) {
            return t.nextAnimationTile != nil
        } else {
            return false
        }
    }
    
    static func isResidentialClear(tile: UInt16) -> Bool {
        assert(tile & LOMASK == tile, "Upper bits set!")
        
        return tile >= RESBASE && tile <= RESBASE + 8
    }
}
