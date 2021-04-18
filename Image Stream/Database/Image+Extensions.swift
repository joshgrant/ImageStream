//
//  Image+Extensions.swift
//  Image Stream
//
//  Created by Joshua Grant on 5/10/20.
//  Copyright © 2020 Joshua Grant. All rights reserved.
//

import CoreData

extension ProcessedImage
{
	
}

extension Image
{
	func imageConstraints(in rect: CGRect, idealSize: CGFloat, verticalOffset: CGFloat) -> (CGPoint, CGSize)?
	{
        if Defaults.centerOnFace, let boundingBox = boundingBox
        {
            let imageSize = size
            
            let fullBoundingBox = CGRect(x: boundingBox.origin.x * imageSize.width,
                                         y: boundingBox.origin.y * imageSize.height,
                                         width: boundingBox.width * imageSize.width,
                                         height: boundingBox.height * imageSize.height)
            
            let scaleFactor = idealSize / fullBoundingBox.width
            
            let newSize = CGSize(width: imageSize.width * scaleFactor,
                                 height: imageSize.height * scaleFactor)
            
            
            // Why not multiply by greater than 1????
            let offset = CGPoint(x: (image.size.width / 2 - (fullBoundingBox.origin.x + fullBoundingBox.width / 2)) * scaleFactor,
                                 y: -(image.size.height / 2 - (fullBoundingBox.origin.y + fullBoundingBox.height / 2)) * scaleFactor - verticalOffset)
            
            return (offset, newSize)
        }
        else if !(Defaults.hideNonFaceImages && Defaults.centerOnFace) // center on image
		{
			let imageSize = image.size
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
			
            return (.zero, scaledImageSize)
		}
        
        return nil
	}
}
