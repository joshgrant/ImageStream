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
		let contents = try? contentsOfDirectory(atPath: directory.path)
		
		let urls = contents?.compactMap({ component -> URL? in
			if component.contains(".jpg") || component.contains(".png") || component.contains(".jpeg")
			{
				return directory.appendingPathComponent(component)
			}
			else
			{
				return nil
			}
		})
		
		return urls ?? []
	}
}
