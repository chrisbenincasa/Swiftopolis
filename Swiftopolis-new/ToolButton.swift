//
//  ToolButton.swift
//  Swiftopolis
//
//  Created by Christian Benincasa on 3/11/15.
//  Copyright (c) 2015 Christian Benincasa. All rights reserved.
//

import Foundation
import SpriteKit

struct ToolButtonHelpers {
    static let SMALL_BUTTON_SIZE = CGSize(width: 34, height: 34)
    static let MEDIUM_BUTTON_SIZE = CGSize(width: 42, height: 42)
    static let LARGE_BUTTON_SIZE = CGSize(width: 58, height: 58)
    static let LONG_BUTTON_SIZE = CGSize(width: 56, height: 24)
    static let TALL_BUTTON_SIZE = CGSize(width: 34, height: 50)
    static let ToolButtonTextures = CachedTextureAtlas.vend("Icons")
}

class ToolButton: SKSpriteNode {
    
    private var on: Bool = false
    private var onTexture: SKTexture?
    private var offTexture: SKTexture?
    private var tool: Tool
    
    required init(buttonName: String, size _size: CGSize, tool _tool: Tool) {
        let offTex = ToolButtonHelpers.ToolButtonTextures.cachedTextures[buttonName + ".png"]
        tool = _tool
        super.init(texture: offTex, color: NSColor.clearColor(), size: _size)
        onTexture = ToolButtonHelpers.ToolButtonTextures.cachedTextures[buttonName + "hi.png"]
        offTexture = offTex
        name = buttonName
        anchorPoint = CGPoint.zero
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggle() {
        texture = on ? offTexture : onTexture        
        on = !on
    }
    
    override func mouseUp(theEvent: NSEvent) {
        (parent as? ToolButtonPanel).foreach { panel in
            panel.toolClicked(self.tool)
        }
    }
}
