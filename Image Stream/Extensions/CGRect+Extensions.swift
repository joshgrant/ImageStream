//
//  CGRect+Extensions.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/12/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Foundation

extension CGRect
{
    var center: CGPoint
    {
        return CGPoint(x: origin.x + width / 2, y: origin.y + height / 2)
    }
}
