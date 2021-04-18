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
    
    static func loadImages(from urls: [URL], progress: @escaping ProgressHandler, completion: @escaping CompletionHandler)
    {
        let group = DispatchGroup()
        var images: [Image] = []
        var current: Int = 0
        
        // This is just to update the loading view...
        progress(0)
        
        for url in urls
        {
            group.enter()
            let image = NSImage(byReferencing: url)
            
            if Defaults.analyzeFaces
            {
                Image.analyzeForFacialLandmarks(image: image) { faces in
//                    if faces.count > 0 {
                        // We don't want to add this image if we're analyzing faces
                        // and no faces were detected
                        images.append(Image(image: image, faces: faces))
//                    }
                    current += 1
                    progress(Double(current))
                    group.leave()
                }
            }
            else
            {
                images.append(Image(image: image))
                current += 1
                progress(Double(current))
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(images)
        }
    }
}
