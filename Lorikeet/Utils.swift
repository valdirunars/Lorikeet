//
//  Utils.swift
//  Lorikeet
//
//  Created by Þorvaldur Rúnarsson on 29/10/2017.
//  Copyright © 2017 Thorvaldur. All rights reserved.
//

import Foundation

struct Utils {
    static func hsv2Color(h: CGFloat, s: CGFloat = 0.5, v: CGFloat = 0.95, alpha: CGFloat) -> UIColor {
        // Converts HSV to a RGB color
        var r: CGFloat
        var g: CGFloat
        var b: CGFloat
        
        let i = Int(h * 6)
        let f = h * 6 - CGFloat(i)
        let p = v * (1 - s)
        let q = v * (1 - f * s)
        let t = v * (1 - (1 - f) * s)
        switch (i % 6) {
        case 0: r = v; g = t; b = p; break;
            
        case 1: r = q; g = v; b = p; break;
            
        case 2: r = p; g = v; b = t; break;
            
        case 3: r = p; g = q; b = v; break;
            
        case 4: r = t; g = p; b = v; break;
            
        case 5: r = v; g = p; b = q; break;
            
        default: r = v; g = t; b = p;
        }
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
        
    }
}
