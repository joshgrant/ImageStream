//
//  MainWindowController.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/12/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController
{
    lazy var windowFrame: CGRect = {
        guard let screenFrame = NSScreen.main?.visibleFrame else { fatalError() }
        
        let width: CGFloat = screenFrame.width / 2
        let height: CGFloat = screenFrame.height / 2
        
        let x = screenFrame.width / 2 - width / 2
        let y = screenFrame.height / 2 - height / 2
        
        return NSRect(x: x, y: y, width: width, height: height)
    }()
    
    override func showWindow(_ sender: Any?)
    {
        super.showWindow(sender)
        
        if Defaults.zoomAtLaunch
        {
            window?.setFrame(windowFrame, display: true, animate: true)
        }
    }
}
