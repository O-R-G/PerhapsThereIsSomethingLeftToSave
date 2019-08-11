//
//  SpriteScreenSaverView.swift
//  SwiftScreenSaver
//
//  Created by Eric Li on 10/03/18.
//  Copyright © O-R-G inc. All rights reserved.
//

import Cocoa
import SpriteKit

class SpriteScreenSaverView: SKView {
    override var acceptsFirstResponder: Bool { return false }
    
    override var frame: NSRect {
        didSet
        {
            self.scene?.size = frame.size
        }
    }
    
}
