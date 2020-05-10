//
//  AppDelegate.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    lazy var mainController: MainWindowController = {
        let mainController = MainViewController.loadFromNib()
        let window = NSWindow(contentViewController: mainController)
        window.title = "Image Stream"
        return MainWindowController(window: window)
    }()
    
    lazy var preferencesController: PreferencesWindowController = {
        let preferencesController = PreferencesViewController.loadFromNib()
        let window = NSWindow(contentViewController: preferencesController)
        window.title = "Preferences"
        return PreferencesWindowController(window: window)
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
	{
        mainController.showWindow(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification)
	{
        // Insert code here to tear down your application
    }
    
    @IBAction func preferences(_ sender: NSMenuItem)
    {
        preferencesController.showWindow(self)
    }
}

