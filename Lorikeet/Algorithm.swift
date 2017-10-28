//
//  Algorithm.swift
//  Lorikeet
//
//  Created by Þorvaldur Rúnarsson on 28/10/2017.
//  Copyright © 2017 Thorvaldur. All rights reserved.
//

import Foundation

public enum Algorithm {
    case cie76
    case cie94
    case cie2000
    
    case advancedCIE94(l: Float, c: Float, h: Float, k1: Float, k2: Float)
    case advancedCIE2000(l: Float, c: Float, h: Float)
}
