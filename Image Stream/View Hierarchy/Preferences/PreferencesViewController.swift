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
    @IBOutlet weak var hideNonFaceImageButton: NSButton!

    // MARK: - View lifecycle
    
    override func viewDidLoad()
	{
        super.viewDidLoad()
        
        centerOnImageCheckbox.boolState = Defaults.centerOnImage
        centerOnFaceCheckbox.boolState = Defaults.centerOnFace
        analyzeFacesCheckbox.boolState = Defaults.analyzeFaces
        showFPSCheckbox.boolState = Defaults.showFPS
        zoomAtLaunch.boolState = Defaults.zoomAtLaunch
        hideNonFaceImageButton.boolState = Defaults.hideNonFaceImages
    }
    
    @IBAction func centerOnImage(sender: NSButton)
    {
        Defaults.centerOnImage = sender.boolState
        
        Defaults.centerOnFace = !sender.boolState
        centerOnFaceCheckbox.boolState = Defaults.centerOnFace
        
        // If "center on image" is off, and "analyze faces is off"
        if !sender.boolState && !Defaults.analyzeFaces
        {
            // We turn on "analyze faces"
            Defaults.analyzeFaces = true
            analyzeFacesCheckbox.boolState = true
        }
    }
    
    @IBAction func centerOnFace(sender: NSButton)
    {
        Defaults.centerOnFace = sender.boolState
        
        Defaults.centerOnImage = !sender.boolState
        centerOnImageCheckbox.boolState = Defaults.centerOnImage
        
        // If we're centering on face
        if sender.boolState
        {
            // We want to make sure that "analyze faces" is turned on
            Defaults.analyzeFaces = true
            
            // We also want to make sure that the UI is updated
            analyzeFacesCheckbox.boolState = true
        }
    }
    
    @IBAction func analyzeFaces(sender: NSButton)
    {
        Defaults.analyzeFaces = sender.boolState
        
        // If we turn off analyze faces
        if !sender.boolState
        {
            // It should turn off "center on face"
            Defaults.centerOnFace = false
            centerOnFaceCheckbox.boolState = false
            
            // and it should turn on "center on image"
            Defaults.centerOnImage = true
            centerOnImageCheckbox.boolState = true
        }
    }
    
    @IBAction func showFPS(sender: NSButton)
    {
        Defaults.showFPS = sender.boolState
    }
    
    @IBAction func zoomAtLaunch(sender: NSButton)
    {
        Defaults.zoomAtLaunch = sender.boolState
    }
    
    @IBAction func hideNonFaceImages(sender: NSButton)
    {
        Defaults.hideNonFaceImages = sender.boolState
    }
}
