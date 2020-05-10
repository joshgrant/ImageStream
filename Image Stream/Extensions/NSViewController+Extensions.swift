//
//  NSViewController+Extensions.swift
//  Image Stream
//
//  Created by Joshua Grant on 5/10/20.
//  Copyright © 2020 Joshua Grant. All rights reserved.
//

import Cocoa

extension NSViewController
{
	static func loadFromNib() -> Self
	{
		var objects: NSArray? = nil
		let nibName = String(describing: self)
		
		Bundle.main.loadNibNamed(nibName, owner: nil, topLevelObjects: &objects)
		
		let content = objects?.first {
			return $0 is Self
		}
		
		return content as! Self
	}
}
