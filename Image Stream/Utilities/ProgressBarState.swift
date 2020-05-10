//
//  ProgressBarState.swift
//  Image Stream
//
//  Created by Joshua Grant on 5/10/20.
//  Copyright © 2020 Joshua Grant. All rights reserved.
//

import Foundation

enum ProgressBarState
{
	case hidden
	case indeterminate
	case empty
	case updating(value: Double, max: Double)
}
