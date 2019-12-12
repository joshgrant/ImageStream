//
//  PreferencesViewController.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController
{
    // MARK: - Variables
    
    // MARK: Interface outlets
    
    @IBOutlet weak var centerOnImageCheckbox: NSButton!
    @IBOutlet weak var centerOnFaceCheckbox: NSButton!
    @IBOutlet weak var analyzeFacesCheckbox: NSButton!
    @IBOutlet weak var showFPSCheckbox: NSButton!
    @IBOutlet weak var zoomAtLaunch: NSButton!

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerOnImageCheckbox.boolState = Defaults.centerOnImage
        centerOnFaceCheckbox.boolState = Defaults.centerOnFace
        analyzeFacesCheckbox.boolState = Defaults.analyzeFaces
        showFPSCheckbox.boolState = Defaults.showFPS
        zoomAtLaunch.boolState = Defaults.zoomAtLaunch
    }
    
    @IBAction func centerOnImage(sender: NSButton)
    {
        Defaults.centerOnImage = sender.boolState
    }
    
    @IBAction func centerOnFace(sender: NSButton)
    {
        Defaults.centerOnFace = sender.boolState
    }
    
    @IBAction func analyzeFaces(sender: NSButton)
    {
        Defaults.analyzeFaces = sender.boolState
    }
    
    @IBAction func showFPS(sender: NSButton)
    {
        Defaults.showFPS = sender.boolState
    }
    
    @IBAction func zoomAtLaunch(sender: NSButton)
    {
        Defaults.zoomAtLaunch = sender.boolState
    }
}
