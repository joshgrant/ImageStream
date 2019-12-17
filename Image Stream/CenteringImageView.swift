//
//  CenteringImageView.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/13/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

class CenteringImageView: NSImageView
{
    var analyzedImage: Image? {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    
    override func draw(_ rect: NSRect)
    {
        let start = DispatchTime.now()
        
        // We need to modify the rect so the image draws properly...
        
        if Defaults.centerOnImage
        {
            if analyzedImage?.cachedImage[rect] == nil
            {
                guard let imageSize = analyzedImage?.image.size else { return }
                let imageAspectRatio = imageSize.width / imageSize.height
                let rectAspectRatio = rect.width / rect.height
                
                var scaleFactor: CGFloat = 1
                
                // Should we scale down?
                if imageSize.width > rect.width || imageSize.height > rect.height
                {
                    if imageAspectRatio < rectAspectRatio
                    {
                        scaleFactor = rect.height / imageSize.height
                    }
                    else
                    {
                        scaleFactor = rect.width / imageSize.width
                    }
                }
                
                let scaledImageSize = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
                
                let offset = CGPoint(x: rect.center.x - (imageSize.width * scaleFactor) / 2,
                                     y: rect.center.y - (imageSize.height * scaleFactor) / 2)
                
                let newRect = CGRect(origin: offset, size: scaledImageSize)
                
                analyzedImage?.cachedFrame[rect] = newRect
                analyzedImage?.cachedImage[rect] = NSImage(size: scaledImageSize, flipped: false) { [weak self] rect -> Bool in
                    self?.analyzedImage?.image.draw(in: rect)
                    return true
                }
            }
        }
        else
        {
            if analyzedImage?.cachedImage[rect] == nil
            {
                print("Caching")
                guard let imageSize = analyzedImage?.image.size else { return }
                guard let boundingBox = analyzedImage?.boundingBox else { return }
                
                let boundingBoxInPixels = CGRect(x: boundingBox.origin.x * imageSize.width,
                                                 y: boundingBox.origin.y * imageSize.height,
                                                 width: boundingBox.width * imageSize.width,
                                                 height: boundingBox.height * imageSize.height)
                
                let idealSize: CGFloat = 200 // Every bounding box should be
                
                let scaleFactor = idealSize / boundingBoxInPixels.width // The width and the height are the same
                
                let scaledImageSize = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
                
                let centerOfBoundingBox = boundingBoxInPixels.center
                var centerOfRect = rect.center
                centerOfRect.y += (rect.height * 1 / 6) // Need to move the center up so it's in the top third
                
                let scaledCenterOfBounding = CGPoint(x: centerOfBoundingBox.x * scaleFactor,
                                                     y: centerOfBoundingBox.y * scaleFactor)
                
                let distanceCenters = CGPoint(x: centerOfRect.x - scaledCenterOfBounding.x,
                                              y: centerOfRect.y - scaledCenterOfBounding.y)
                
                let newRect = CGRect(origin: distanceCenters, size: scaledImageSize)
                
                analyzedImage?.cachedFrame[rect] = newRect
                analyzedImage?.cachedImage[rect] = NSImage(size: scaledImageSize, flipped: false) { [weak self] rect -> Bool in
                    self?.analyzedImage?.image.draw(in: rect)
                    return true
                }
            }
        }
        
        guard let newRect = analyzedImage?.cachedFrame[rect] else { return }
        guard let image = analyzedImage?.cachedImage[rect] else { return }
        image.draw(in: newRect)
        
        let end = DispatchTime.now()
        
        let duration = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
        print(duration)
    }
}
