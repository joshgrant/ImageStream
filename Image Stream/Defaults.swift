//
//  Defaults.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Foundation

@propertyWrapper struct Defaults
{
    var key: String
    var defaultValue: Bool
    
    var hasSetKey: String { return "hasSet_\(key)" }
    var hasSetValue: Bool { return UserDefaults.standard.bool(forKey: hasSetKey) }
    
    var wrappedValue: Bool
    {
        get
        {
            if !hasSetValue
            {
                UserDefaults.standard.set(defaultValue, forKey: key)
                UserDefaults.standard.set(true, forKey: hasSetKey)
            }
            
            return UserDefaults.standard.bool(forKey: key)
        }
        set
        {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
}

extension Defaults
{
    @Defaults(key: "hideNonFaceImages", defaultValue: true) static var hideNonFaceImages: Bool
    @Defaults(key: "centerOnImage", defaultValue: true) static var centerOnImage: Bool
    @Defaults(key: "centerOnFace", defaultValue: true) static var centerOnFace: Bool
    @Defaults(key: "analyzeFaces", defaultValue: true) static var analyzeFaces: Bool
    @Defaults(key: "showFPS", defaultValue: true) static var showFPS: Bool
    @Defaults(key: "zoomAtLaunch", defaultValue: true) static var zoomAtLaunch: Bool
}
