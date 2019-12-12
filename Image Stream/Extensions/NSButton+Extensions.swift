//
//  NSButton+Extensions.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/12/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

extension NSButton
{
    var boolState: Bool
    {
        get
        {
            switch state
            {
            case .on:
                return true
            case .off:
                return false
            default:
                return false
            }
        }
        set
        {
            switch newValue
            {
            case true:
                state = .on
            case false:
                state = .off
            }
        }
    }
}
