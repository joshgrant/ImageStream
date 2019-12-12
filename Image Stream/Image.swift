//
//  Image.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa
import Vision

class Image
{
    var image: NSImage
    var faces: [VNFaceObservation]
    
    init(image: NSImage, faces: [VNFaceObservation] = [])
    {
        self.image = image
        self.faces = faces
    }
}
