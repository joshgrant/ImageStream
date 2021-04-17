//
//  MainView.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/21/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

class MainView: NSView
{
    override var acceptsFirstResponder: Bool { return true }
    
    // MARK: - Drag and drop support
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.layer?.backgroundColor = NSColor.blue.cgColor
        return NSDragOperation()
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .link
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool
    {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = pasteboard[0] as? String
        else { return false }
        
        print("Path: \(path)")
        
        return true
    }
}
