//
//  Lorikeet.swift
//  Lorikeet
//
//  Created by Þorvaldur Rúnarsson on 28/10/2017.
//  Copyright © 2017 Thorvaldur. All rights reserved.
//

import UIKit

public struct Lorikeet {
    let color: UIColor
    
    init(_ color: UIColor) {
        self.color = color
    }

    private static func rgba(for color: UIColor) -> [Float] {
        var rgba: [CGFloat] = [0,0,0,0]
        color.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
        return rgba.map { float -> Float in Float(float) }
    }

    private static func xyz(for uiColor: UIColor) -> [Float] {
        
        let rgba: [Float] = Lorikeet.rgba(for: uiColor)
        
        let xyz_helper: (Float) -> Float = { c -> Float in
            let k1: Float = 0.04045
            let k2: Float = 0.055
            let k3: Float = 1.055
            let k4: Float = 2.4
            let k5: Float = 12.92
            let aHundred: Float = 100

            return (k1 < c ? pow((c + k2)/k3, k4) : c/k5) * aHundred
        }
        
        let r: Float = xyz_helper(rgba[0])
        let g: Float = xyz_helper(rgba[1])
        let b: Float = xyz_helper(rgba[2])
        
        let x: Float = (r * 0.4124) + (g * 0.3576) + (b * 0.1805)
        let y: Float = (r * 0.2126) + (g * 0.7152) + (b * 0.0722)
        let z: Float = (r * 0.0193) + (g * 0.1192) + (b * 0.9505)
        
        return [ x, y, z ]
    }
    
    private static func lab(for color: UIColor) -> LabVector {
        
        let xyz = Lorikeet.xyz(for: color)
        
        let lab_helper: (Float) -> Float = { c -> Float in
            let k1: Float = 0.008856
            let k2: Float = 7.787
            let aThird: Float = 1.0/3.0
            let sixteenOverOneSixteen: Float = 16.0 / 116.0

            return k1 < c ? pow(c, aThird) : ((k2 * c) + sixteenOverOneSixteen)
        }
        
        let k1: Float = 95.047
        let k2: Float = 100.0
        let k3: Float = 108.883
        
        let x: Float = lab_helper(xyz[0]/k1)
        let y: Float = lab_helper(xyz[1]/k2)
        let z: Float = lab_helper(xyz[2]/k3)
        
        let l: Float = (116 * y) - 16
        let a: Float = 500 * (x - y)
        let b: Float = 200 * (y - z)
        
        return (l, a, b)
    }
    
    public func distance(to otherColor: UIColor, algorithm: Algorithm) -> Float {
        let lab1 = Lorikeet.lab(for: self.color)
        let lab2 = Lorikeet.lab(for: otherColor)
        
        switch algorithm {
        case .cie76:
            return CIE76SquaredColorDifference(lab1: lab1, lab2: lab2)
        case .cie94:
            return CIE94SquaredColorDifference()(lab1, lab2)
        case .cie2000:
            return CIE2000SquaredColorDifference()(lab1, lab2)
        case .advancedCIE94(l: let l, c: let c, h: let h, k1: let k1, k2: let k2):
            return CIE94SquaredColorDifference(kL: l, kC: c, kH: h, k1: k1, k2: k2)(lab1, lab2)
        case .advancedCIE2000(l: let l, c: let c, h: let h):
            return CIE2000SquaredColorDifference(kL: l, kC: c, kH: h)(lab1, lab2)
        }
    }
    
    public func generateRandomMatchingColor() -> UIColor {
        var red: CGFloat = CGFloat(arc4random() % 256)
        var green: CGFloat = CGFloat(arc4random() % 256)
        var blue: CGFloat = CGFloat(arc4random() % 256)
        
        let rgba = Lorikeet.rgba(for: self.color).map { CGFloat($0) }
        
        red = (rgba[0] + red) / CGFloat(2.0)
        green = (rgba[1] + green) / CGFloat(2.0)
        blue = (rgba[2] + blue) / CGFloat(2.0)
        
        let twoFiftyFive: CGFloat = 255.0
        return UIColor(red: red / twoFiftyFive, green: green / twoFiftyFive, blue: blue / twoFiftyFive, alpha: rgba[3])
    }
    
    public func generateColorScheme(numberOfColors: Int, using algorithm: Algorithm = .cie2000, completion: (([UIColor]) -> Void)? = nil) {
        var colors: [UIColor] = [ self.color ]

        if numberOfColors == 0 {
            completion?(colors)
            return
        }
        
        var minColorDistance: Float = 45.0
        let maxRetries = 20
        var retries = 0

        var offset: Float = 1.5
        
        let offsetOffset: Float = 0.01

        let minOffset: Float = offset - Float(maxRetries) * offsetOffset
        
        while colors.count != numberOfColors {
            let color = self.generateRandomMatchingColor()
            
            
            var minDistance: Float = 1_000_000 // just some high number

            for col in colors {
                let distance = col.lkt.distance(to: color, algorithm: algorithm)
                if minDistance > distance {
                    minDistance = distance
                }
            }
            
            if minDistance < minColorDistance {

                retries = retries + 1

                if retries == maxRetries {
//                    print("failed to get colors with diff: \(minDifference)")
                    retries = 0
                    minColorDistance -= offset
                    
                    if offset > minOffset {
                        offset -= offsetOffset
                    }
                }

            } else {
                colors.append(color)
            }
            
        }

        completion?(colors)
    }
}
