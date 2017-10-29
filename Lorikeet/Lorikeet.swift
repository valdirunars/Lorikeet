//
//  Lorikeet.swift
//  Lorikeet
//
//  Created by Þorvaldur Rúnarsson on 28/10/2017.
//  Copyright © 2017 Thorvaldur. All rights reserved.
//

import UIKit

public enum ColorType {
    case flat(brightnessFactor: Float)
    case pastel(brightnessFactor: Float)
}

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
    
    public func generateRandomMatchingColor(colorType: ColorType = .flat(brightnessFactor: 1)) -> UIColor {
        let twoFiftyFive: CGFloat = 255.0

        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat

        switch colorType {
        case .flat(brightnessFactor: let brightnessFactor):
            var rgOrB = Int(arc4random() % 3)
            var redAddition: CGFloat = rgOrB == 0 ? 63.5 : 0
            var greenAddition: CGFloat = rgOrB == 1 ? 63.5 : 0
            var blueAddition: CGFloat = rgOrB == 2 ? 63.5 : 0

            let next = (rgOrB + Int(arc4random() % 3)) % 3
            if next != rgOrB {
                rgOrB = next
                redAddition = redAddition + (rgOrB == 0 ? 63.5 : 0)
                greenAddition = greenAddition + (rgOrB == 1 ? 63.5 : 0)
                blueAddition = blueAddition + (rgOrB == 2 ? 63.5 : 0)
            }

            redAddition *= CGFloat(brightnessFactor)
            greenAddition *= CGFloat(brightnessFactor)
            blueAddition *= CGFloat(brightnessFactor)
            
            red = CGFloat(arc4random() % 127) + (127 * CGFloat(brightnessFactor)) + redAddition
            green = CGFloat(arc4random() % 127) + (127 * CGFloat(brightnessFactor)) + greenAddition
            blue = CGFloat(arc4random() % 127) + (127 * CGFloat(brightnessFactor)) + blueAddition
        case .pastel(brightnessFactor: let brightnessFactor):
            
            red = CGFloat(arc4random() % 127) + (127 * CGFloat(brightnessFactor))
            green = CGFloat(arc4random() % 127) + (127 * CGFloat(brightnessFactor))
            blue = CGFloat(arc4random() % 127) + (127 * CGFloat(brightnessFactor))
        }
        
        let rgba = Lorikeet.rgba(for: self.color).map { CGFloat($0) }
        
        red = (rgba[0] + red) / CGFloat(2.0)
        green = (rgba[1] + green) / CGFloat(2.0)
        blue = (rgba[2] + blue) / CGFloat(2.0)
        
        return UIColor(red: red / twoFiftyFive, green: green / twoFiftyFive, blue: blue / twoFiftyFive, alpha: rgba[3])
    }
    
    public func generateColorScheme(numberOfColors: Int,
                                    colorType: ColorType = .flat(brightnessFactor: 1),
                                    using algorithm: Algorithm = .cie2000,
                                    completion: (([UIColor]) -> Void)? = nil) {
        let complete: ([UIColor]) -> Void = { colors in
            DispatchQueue.main.async {
                completion?(colors)
            }
        }

        DispatchQueue.global(qos: .background).async {
            var colors: [UIColor] = [ self.color ]
            
            if numberOfColors == 0 {
                complete(colors)
                return
            }
            let originalMinColorDistance: Float = 45.0
            var minColorDistance: Float = originalMinColorDistance
            let maxRetries = 20
            var retries = 0
            
            var offset: Float = 1.5
            
            let offsetOffset: Float = 0.01
            
            let minOffset: Float = offset - Float(maxRetries) * offsetOffset
            
            while colors.count != numberOfColors {
                let color = colors.reduce(self.color, { (result, color) -> UIColor in
                    let rgba1 = Lorikeet.rgba(for: result).map { CGFloat($0) }
                    let rgba2 = Lorikeet.rgba(for: color).map { CGFloat($0) }
                    
                    let red: CGFloat = (rgba1[0] + rgba2[0]) / 2.0
                    let green: CGFloat = (rgba1[1] + rgba2[1]) / 2.0
                    let blue: CGFloat = (rgba1[2] + rgba2[2]) / 2.0
                    let alpha: CGFloat = (rgba1[3] + rgba2[3]) / 2.0
                    return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
                })
                .lkt.generateRandomMatchingColor(colorType: colorType)
                
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
                    minColorDistance = originalMinColorDistance
                }
                
            }
            
            complete(colors)
        }
    }
}
