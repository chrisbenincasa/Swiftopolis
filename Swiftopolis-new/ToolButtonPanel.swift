//
//  ToolButtonPanel.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 3/11/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import SpriteKit

class ToolButtonPanel: SKNode {
    private let SPACE_BETWEEN_BUTTONS: CGFloat = 10.0
    private(set) var buttonsByTool: [Tool : ToolButton] = [:]
    private(set) var currentTool: Tool?
    private var cachedTextures: CachedTextureAtlas!
    
    override init() {
        super.init()
        
        cachedTextures = CachedTextureAtlas.vend("Icons") {
            print("-- preloaded icon textures --")
            self.initButtons()
        }
    }
    
    private func initButtons() {
        var baseline: CGPoint = CGPoint.zero
        
        for (idx, tool) in [Tool.Bulldozer, Tool.Wire, Tool.Park].enumerate() {
            makeButton(tool, size: ToolButtonHelpers.SMALL_BUTTON_SIZE, offset: idx, baseline: baseline)
        }
        
        baseline.y -= ToolButtonHelpers.LONG_BUTTON_SIZE.height + SPACE_BETWEEN_BUTTONS
        
        for (idx, tool) in [Tool.Road, Tool.Rail].enumerate() {
            makeButton(tool, size: ToolButtonHelpers.LONG_BUTTON_SIZE, offset: idx, baseline: baseline)
        }
        
        baseline.y -= ToolButtonHelpers.TALL_BUTTON_SIZE.height + SPACE_BETWEEN_BUTTONS
        
        for (idx, tool) in [Tool.Residential, Tool.Commercial, Tool.Industrial].enumerate() {
            makeButton(tool, size: ToolButtonHelpers.TALL_BUTTON_SIZE, offset: idx, baseline: baseline)
        }
        
        baseline.y -= ToolButtonHelpers.SMALL_BUTTON_SIZE.height + SPACE_BETWEEN_BUTTONS
        
        for (idx, tool) in [Tool.FireStation, Tool.Query, Tool.PoliceStation].enumerate() {
            makeButton(tool, size: ToolButtonHelpers.SMALL_BUTTON_SIZE, offset: idx, baseline: baseline)
        }
        
        baseline.x += SPACE_BETWEEN_BUTTONS
        baseline.y -= ToolButtonHelpers.MEDIUM_BUTTON_SIZE.height + SPACE_BETWEEN_BUTTONS
        
        for (idx, tool) in [Tool.Coal, Tool.Nuclear].enumerate() {
            makeButton(tool, size: ToolButtonHelpers.MEDIUM_BUTTON_SIZE, offset: idx, baseline: baseline)
        }
        
        baseline.y -= ToolButtonHelpers.MEDIUM_BUTTON_SIZE.height + SPACE_BETWEEN_BUTTONS
        
        for (idx, tool) in [Tool.Stadium, Tool.Seaport].enumerate() {
            makeButton(tool, size: ToolButtonHelpers.MEDIUM_BUTTON_SIZE, offset: idx, baseline: baseline)
        }
        
        baseline.x += SPACE_BETWEEN_BUTTONS * 2
        baseline.y -= ToolButtonHelpers.LARGE_BUTTON_SIZE.height + SPACE_BETWEEN_BUTTONS
        
        makeButton(Tool.Airport, size: ToolButtonHelpers.LARGE_BUTTON_SIZE, offset: 0, baseline: baseline)
    }
    
    private func makeButton(tool: Tool, size: CGSize, offset: Int, baseline: CGPoint) {
        let buttonName = NSLocalizedString(tool.rawValue + ".button.name", tableName: "GUIStrings", comment: "")
        let button = ToolButton(buttonName: buttonName, size: size, tool: tool)
        buttonsByTool[tool] = button
        button.position.y = baseline.y
        button.position.x = baseline.x + (size.width * CGFloat(offset) + (SPACE_BETWEEN_BUTTONS * CGFloat(offset)))
        addChild(button)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toolClicked(tool: Tool) {
        if currentTool.isDefined() && currentTool! == tool {
            return
        }
        
        if let clickedTool = buttonsByTool[tool] {
            clickedTool.toggle()
            
            if let currentButton = currentTool.flatMap({self.buttonsByTool[$0]}) {
                currentButton.toggle()
            }
            
            currentTool = tool
        }
        
        if let scene = self.parent as? GameScene {
            scene.setCurrentTool(tool)
        }
    }
}