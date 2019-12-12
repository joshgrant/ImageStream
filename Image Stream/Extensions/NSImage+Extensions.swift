//
//  NSImage+Extensions.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

extension NSImage
{
    var cgImage: CGImage?
    {
        return cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
}
