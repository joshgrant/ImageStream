//
//  Image.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa
import Vision

extension CGSize: Hashable
{
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.width)
        hasher.combine(self.height)
    }
}

extension CGPoint: Hashable
{
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}

extension CGRect: Hashable
{
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.origin)
        hasher.combine(self.size)
    }
}

class Image
{
    var image: NSImage
    /// The key is the image scale... so we can resize it 
    var cachedImage: [CGRect: NSImage] = [:]
    var cachedFrame: [CGRect: CGRect] = [:]
    var faces: [VNFaceObservation]
    
    /// The size is the default size of the image in pixels
    var size: CGSize
    {
        return image.representations.first?.size ?? .zero
    }
    
    /// The bounding box is relative to the size of the image
    var boundingBox: CGRect
    {
        return faces.first?.boundingBox ?? .zero
    }
    
    init(image: NSImage, faces: [VNFaceObservation] = [])
    {
        self.image = image
        self.faces = faces
    }
    
    static func analyzeForFacialLanmarks(image: NSImage, completion: @escaping (([VNFaceObservation]) -> Void))
    {
        let request = VNDetectFaceLandmarksRequest { (request, error) in
            
            if let error = error {
                // Could just return an empty array here...
                fatalError(error.localizedDescription)
            }
            
            guard let observations = request.results as? [VNFaceObservation] else { fatalError() }
            
            completion(observations)
        }
        
        guard let cgImage = image.cgImage else {
            fatalError("Failed to convert an image to a CGImage.")
        }
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .default).async {
            try? imageRequestHandler.perform([request])
        }
    }
}
