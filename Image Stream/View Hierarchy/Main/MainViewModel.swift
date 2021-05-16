//
//  MainViewModel.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

class MainViewModel
{
    typealias ProgressHandler = ((_ total: Double) -> Void)
    typealias CompletionHandler = ((_ images: [Image]) -> Void)
    
    // MARK: - Variables
    
    private var currentImage: Int
    var images: [Image]
    
    // MARK: - Initialization
    
    init()
    {
        currentImage = 0
        images = []
    }
    
    // MARK: - Functions
    
    func image(forward: Bool) -> Image
    {
        currentImage += forward ? 1 : -1
        normalizeCurrentImage() // Not functional...
        return images[currentImage]
    }
    
    private func normalizeCurrentImage()
    {
        if currentImage >= images.count
        {
            currentImage = 0
        }
        else if currentImage < 0
        {
            currentImage = images.count - 1
        }
    }
    
    static func analyzeSingleImage(url: URL) async -> Image? {
        
        let image = NSImage(byReferencing: url)
        
        return await withUnsafeContinuation({ continuation in
            if Defaults.analyzeFaces {
                Image.analyzeForFacialLandmarks(image: image) { faces in
                    if faces.count > 0 { // Only if a face has been detected
                        continuation.resume(returning: Image(image: image, faces: faces))
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            } else {
                continuation.resume(with: .success(Image(image: image)))
            }
        })
    }
    
    static func loadImages(from urls: [URL], progress: @escaping ProgressHandler) async -> [Image]
    {
        var images: [Image] = []
        var current: Double = 0
        
        progress(current)
        
        for url in urls {
            print("Analyzing: \(url)")
            if let image = await analyzeSingleImage(url: url) {
                images.append(image)
                current += 1
                progress(current)
            }
        }
        
        return images
    }
}
