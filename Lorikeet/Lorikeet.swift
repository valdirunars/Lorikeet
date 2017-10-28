//
//  Lorikeet.swift
//  Lorikeet
//
//  Created by Þorvaldur Rúnarsson on 28/10/2017.
//  Copyright © 2017 Thorvaldur. All rights reserved.
//

import UIKit

public struct Lorikeet {
    
    private static func rgba(for color: UIColor) -> [Float] {
        var rgba: [CGFloat] = [0,0,0,0]
        color.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
        return rgba.map { Float($0) }
    }
    
    private static func xyz(for color: UIColor) -> [Float] {
        
        let rgba = Lorikeet.rgba(for: color)
        
        let xyz_helper: (Float) -> Float = { c in
            return (0.04045 < c ? pow((c + 0.055)/1.055, 2.4) : c/12.92) * 100
        }
        
        let r = xyz_helper(rgba[0])
        let g = xyz_helper(rgba[1])
        let b = xyz_helper(rgba[2])
        
        let x: Float = (r * 0.4124) + (g * 0.3576) + (b * 0.1805)
        let y: Float = (r * 0.2126) + (g * 0.7152) + (b * 0.0722)
        let z: Float = (r * 0.0193) + (g * 0.1192) + (b * 0.9505)
        
        return [ x, y, z ]
    }
    
    private static func lab(for color: UIColor) -> LabVector {
        
        let xyz = Lorikeet.xyz(for: color)
        
        let lab_helper: (Float) -> Float = { c in
            return 0.008856 < c ? pow(c, 1/3) : ((7.787 * c) + (16/116))
        }

        let x: Float = lab_helper(xyz[0]/95.047)
        let y: Float = lab_helper(xyz[1]/100.0)
        let z: Float = lab_helper(xyz[2]/108.883)
        
        let l: Float = (116 * y) - 16
        let a: Float = 500 * (x - y)
        let b: Float = 200 * (y - z)
        
        return (l, a, b)
    }
    
    static func colorDifference(leftColor: UIColor, rightColor: UIColor, algorithm: Algorithm) -> Float {
        let lab1 = lab(for: leftColor)
        let lab2 = lab(for: rightColor)
        
        switch algorithm {
        case .cie76:
            return CIE76SquaredColorDifference(lab1, lab2: lab2)
        case .cie94:
            return CIE94SquaredColorDifference()(lab1, lab2)
        case .cie2000:
            return CIE2000SquaredColorDifference()(lab1, lab2)
        }
        
    }
}
