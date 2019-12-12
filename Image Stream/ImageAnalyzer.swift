//
//  ImageAnalyzer.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa
import Vision

class ImageAnalyzer
{
    static func analyzeForFacialLanmarks(image: NSImage, completion: @escaping (([VNFaceObservation]) -> Void))
    {
        let request = VNDetectFaceLandmarksRequest { (request, error) in
            if let error = error {
                // Could just return an empty array here...
                fatalError(error.localizedDescription)
            }
            
            // TODO: Get the request.results
            
            completion([])
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
