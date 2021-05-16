//
//  MainView.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/21/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

protocol MainViewDragDelegate: AnyObject
{
    func mainViewDidDrop(path: String)
}

class MainView: NSView
{
    // MARK: - Variables
    
    override var acceptsFirstResponder: Bool { return true }
    
    weak var delegate: MainViewDragDelegate?
    
    // MARK: - Initialization
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        self.wantsLayer = true
        
        registerForDraggedTypes([.fileURL])
    }
    
    // MARK: - Drag and drop support
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool
    {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = pasteboard[0] as? String
        else { return false }
        
        delegate?.mainViewDidDrop(path: path)
        
        return true
    }
}
