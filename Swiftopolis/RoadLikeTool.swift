//
//  RoadLikeTool.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 1/22/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation

struct RoadLikeConstants {
    static let RAIL_COST = 20
    static let TUNNEL_COST = 100
    static let ROAD_COST = 10
    static let BRIDGE_COST = 50
    static let WIRE_COST = 5
    static let UNDERWATER_WIRE_COST = 25
}

class RoadLikeTool : ToolStroke {
    
    override func applyArea(effect: AbstractToolEffect) {
        while (true) {
            if !applyForward(effect) {
                break
            }
            
            if !applyBackward(effect) {
                break
            }
        }
    }
    
    func applyBackward(effect: AbstractToolEffect) -> Bool {
        var changed = false
        let bounds = getBounds()
        
        for var i = Int(bounds.height - 1); i >= 0; i-- {
            for var j = Int(bounds.width - 1); j >= 0; j-- {
                let translated = OffsetToolEffect(base: effect, dx: Int(bounds.origin.x) + j, dy: Int(bounds.origin.y) + i)
                changed = changed || applySingle(translated)
            }
        }
        
        return changed
    }
    
    func applyForward(effect: AbstractToolEffect) -> Bool {
        var changed = false
        let bounds = getBounds()
        
        for var i = 0; i <= Int(bounds.height - 1); i++ {
            for var j = 0; j <= Int(bounds.width - 1); j++ {
                let translated = OffsetToolEffect(base: effect, dx: Int(bounds.origin.x) + j, dy: Int(bounds.origin.y) + i)
                changed = changed || applySingle(translated)
            }
        }
        
        return changed
    }
    
    override func getBounds() -> NSRect {
        if abs(xDest - xSrc) >= abs(yDest - ySrc) {
            return NSRect(x: min(xSrc, xDest), y: ySrc, width: abs(xDest - xSrc) + 1, height: 1)
        } else {
            return NSRect(x: xSrc, y: min(ySrc, yDest), width: 1, height: abs(yDest - ySrc) + 1)
        }
    }
    
    func applySingle(effect: AbstractToolEffect) -> Bool {
        switch tool {
        case .Rail: return applyRailTool(effect)
        case .Road: return applyRoadTool(effect)
        case .Wire: return applyWireTool(effect)
        default: fatalError("BAD BAD BAD")
        }
    }
    
    private func applyRailTool(effect: AbstractToolEffect) -> Bool {
        if layRail(effect) {
            fixZone(effect)
            return true
        } else {
            return false
        }
    }
    
    private func applyRoadTool(effect: AbstractToolEffect) -> Bool {
        if layRoad(effect) {
            fixZone(effect)
            return true
        } else {
            return false
        }
    }
    
    private func applyWireTool(effect: AbstractToolEffect) -> Bool {
        if layWire(effect) {
            fixZone(effect)
            return true
        } else {
            return false
        }
    }
    
    // TODO: make these functions prettier and more DRY
    
    private func layRail(effect: AbstractToolEffect) -> Bool {
        var baseCost = RoadLikeConstants.RAIL_COST
        
        let tile = TileConstants.normalizeRoad(effect.getTile(0, 0))
        
        switch tile {
        case TileConstants.RIVER, TileConstants.REDGE, TileConstants.CHANNEL:
            baseCost = RoadLikeConstants.TUNNEL_COST
            let eastTile = TileConstants.normalizeRoad(effect.getTile(1, 0))
            let northTile = TileConstants.normalizeRoad(effect.getTile(0, 1))
            let southTile = TileConstants.normalizeRoad(effect.getTile(0, -1))
            let westTile = TileConstants.normalizeRoad(effect.getTile(-1, 0))
            
            if eastTile == TileConstants.RAILHPOWERV ||
                eastTile == TileConstants.HRAIL ||
                (eastTile >= TileConstants.LHRAIL && eastTile <= TileConstants.HRAILROAD) {
                
                    effect.setTile(0, 0, TileConstants.HRAIL)
                    break
            }
            
            if westTile == TileConstants.RAILHPOWERV ||
                westTile == TileConstants.HRAIL ||
                (westTile >= TileConstants.VRAIL && westTile <= TileConstants.VRAILROAD) {
                    
                    effect.setTile(0, 0, TileConstants.HRAIL)
                    break
            }
            
            if northTile == TileConstants.RAILVPOWERH ||
                northTile == TileConstants.VRAILROAD ||
                (northTile >= TileConstants.HRAIL && northTile <= TileConstants.HRAILROAD) {
                    
                    effect.setTile(0, 0, TileConstants.VRAIL)
                    break
            }
            
            if southTile == TileConstants.RAILVPOWERH ||
                southTile == TileConstants.VRAILROAD ||
                (southTile >= TileConstants.HRAIL && southTile <= TileConstants.HRAILROAD) {
                    
                    effect.setTile(0, 0, TileConstants.VRAIL)
                    break
            }
            
            return false
        case TileConstants.LHPOWER: // Rail on power
            effect.setTile(0, 0, TileConstants.RAILVPOWERH)
            break
        case TileConstants.LVPOWER:
            effect.setTile(0, 0, TileConstants.RAILHPOWERV)
            break
        case TileConstants.ROADS:
            effect.setTile(0, 0, TileConstants.VRAILROAD)
            break
        case TileConstants.ROADS2:
            effect.setTile(0, 0, TileConstants.HRAILROAD)
            break
        default:
            if tile != TileConstants.DIRT {
                if city.autoBulldoze && TileConstants.canAutoBulldozeRRW(tile) {
                    baseCost += 1
                } else {
                    return false
                }
            }
            
            effect.setTile(0, 0, TileConstants.LHRAIL)
            break
        }
        
        effect.spend(baseCost)
        return true
    }
    
    private func layRoad(effect: AbstractToolEffect) -> Bool {
        var baseCost = RoadLikeConstants.ROAD_COST
        
        let tile = effect.getTile(0, 0)
        
        switch tile {
        case TileConstants.RIVER, TileConstants.REDGE, TileConstants.CHANNEL:
            baseCost = RoadLikeConstants.BRIDGE_COST
            let eastTile = TileConstants.normalizeRoad(effect.getTile(1, 0))
            let northTile = TileConstants.normalizeRoad(effect.getTile(0, 1))
            let southTile = TileConstants.normalizeRoad(effect.getTile(0, -1))
            let westTile = TileConstants.normalizeRoad(effect.getTile(-1, 0))
            
            if eastTile == TileConstants.VRAILROAD ||
                eastTile == TileConstants.HBRIDGE ||
                (eastTile >= TileConstants.ROADS && eastTile <= TileConstants.HROADPOWER) {
                    
                    effect.setTile(0, 0, TileConstants.HBRIDGE)
                    break
            }
            
            if westTile == TileConstants.VRAILROAD ||
                westTile == TileConstants.HBRIDGE ||
                (westTile >= TileConstants.ROADS && westTile <= TileConstants.INTERSECTION) {
                    
                    effect.setTile(0, 0, TileConstants.HBRIDGE)
                    break
            }
            
            if northTile == TileConstants.HRAILROAD ||
                northTile == TileConstants.VROADPOWER ||
                (northTile >= TileConstants.VBRIDGE && northTile <= TileConstants.INTERSECTION) {
                    
                    effect.setTile(0, 0, TileConstants.VBRIDGE)
                    break
            }
            
            if southTile == TileConstants.HRAILROAD ||
                southTile == TileConstants.VROADPOWER ||
                (southTile >= TileConstants.VBRIDGE && southTile <= TileConstants.INTERSECTION) {
                    
                    effect.setTile(0, 0, TileConstants.VBRIDGE)
                    break
            }
            
            return false
        case TileConstants.LHPOWER:
            effect.setTile(0, 0, TileConstants.VROADPOWER)
            break
        case TileConstants.LVPOWER:
            effect.setTile(0, 0, TileConstants.HROADPOWER)
            break
        case TileConstants.LHRAIL:
            effect.setTile(0, 0, TileConstants.HRAILROAD)
            break
        case TileConstants.LVRAIL:
            effect.setTile(0, 0, TileConstants.VRAILROAD)
            break
        default:
            if tile != TileConstants.DIRT {
                if city.autoBulldoze && TileConstants.canAutoBulldozeRRW(tile) {
                    baseCost++
                } else {
                    return false
                }
            }
            
            effect.setTile(0, 0, TileConstants.ROADS)
            break
        }
        
        effect.spend(baseCost)
        return true
    }
    
    private func layWire(effect: AbstractToolEffect) -> Bool {
        var baseCost = RoadLikeConstants.WIRE_COST
        
        let tile = effect.getTile(0, 0)
        
        switch tile {
        case TileConstants.RIVER, TileConstants.REDGE, TileConstants.CHANNEL:
            baseCost = RoadLikeConstants.UNDERWATER_WIRE_COST
            let eastTile = TileConstants.normalizeRoad(effect.getTile(1, 0))
            let northTile = TileConstants.normalizeRoad(effect.getTile(0, 1))
            let southTile = TileConstants.normalizeRoad(effect.getTile(0, -1))
            let westTile = TileConstants.normalizeRoad(effect.getTile(-1, 0))
            
            if TileConstants.isConductive(eastTile) &&
                eastTile != TileConstants.HROADPOWER &&
                eastTile != TileConstants.RAILHPOWERV &&
                eastTile != TileConstants.HPOWER {
                    
                    effect.setTile(0, 0, TileConstants.VPOWER)
                    break
            }
            
            if TileConstants.isConductive(westTile) &&
                westTile != TileConstants.HROADPOWER &&
                westTile != TileConstants.RAILHPOWERV &&
                westTile != TileConstants.HPOWER {
                    
                    effect.setTile(0, 0, TileConstants.VPOWER)
                    break
            }
            
            if TileConstants.isConductive(southTile) &&
                southTile != TileConstants.VROADPOWER &&
                southTile != TileConstants.RAILVPOWERH &&
                southTile != TileConstants.VPOWER {
                    
                    effect.setTile(0, 0, TileConstants.HPOWER)
                    break
            }
            
            if TileConstants.isConductive(northTile) &&
                northTile != TileConstants.VROADPOWER &&
                northTile != TileConstants.RAILVPOWERH &&
                northTile != TileConstants.VPOWER {
                    
                    effect.setTile(0, 0, TileConstants.VPOWER)
                    break
            }
            
            return false
        case TileConstants.ROADS:
            effect.setTile(0, 0, TileConstants.HROADPOWER)
            break
        case TileConstants.ROADS2:
            effect.setTile(0, 0, TileConstants.VROADPOWER)
            break
        case TileConstants.LHRAIL:
            effect.setTile(0, 0, TileConstants.RAILHPOWERV)
            break
        case TileConstants.LVRAIL:
            effect.setTile(0, 0, TileConstants.RAILVPOWERH)
            break
        default:
            if tile != TileConstants.DIRT {
                if city.autoBulldoze && TileConstants.canAutoBulldozeRRW(tile) {
                    baseCost++
                } else {
                    return false
                }
            }
            
            effect.setTile(0, 0, TileConstants.LHPOWER)
            break
        }
        
        effect.spend(baseCost)
        return true
    }
}