//
//  FileManager+Extensions.swift
//  Image Stream
//
//  Created by Joshua Grant on 5/10/20.
//  Copyright © 2020 Joshua Grant. All rights reserved.
//

import Foundation

extension FileManager
{
	func imagesIn(directory: URL) -> [URL]
	{
        // This returns an array with undefined values
        // Let's sort it... by? Name?
        let contents = try? contentsOfDirectory(atPath: directory.path).sorted(by: { $0.localizedStandardCompare($1) == .orderedAscending })
        
        let acceptableExtensions = [".jpg", ".png", ".jpeg", ".webp", ".tif", ".tiff"]
		
		let urls = contents?.compactMap({ component -> URL? in
            
            for ext in acceptableExtensions {
                if component.contains(ext) {
                    return directory.appendingPathComponent(component)
                }
            }
            
            return nil
		})
		
		return urls ?? []
	}
}
