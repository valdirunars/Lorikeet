//
//  DeltaE.swift
//  Lorikeet
//
//  Created by Þorvaldur Rúnarsson on 27/10/2017.
//  Copyright © 2017 Thorvaldur. All rights reserved.
//

import Foundation

internal extension Float {
    var degreesToRadians: Float { return Float(self) * .pi / 180 }
}
internal extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

internal typealias LabVector = (l: Float, a: Float, b: Float)

// From http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE76.html
internal func CIE76SquaredColorDifference(_ lab1: LabVector, lab2: LabVector) -> Float {
    let l1 = lab1.l
    let a1 = lab1.a
    let b1 = lab1.b
    
    let l2 = lab2.l
    let a2 = lab2.a
    let b2 = lab2.b
    
    return pow(l2 - l1, 2) + pow(a2 - a1, 2) + pow(b2 - b1, 2)
}

private func pythagorasC(_ a: Float, b: Float) -> Float {
    return sqrt(pow(a, 2) + pow(b, 2))
}

// Swiftified version of Bruce Lindbloom's math equation for Delta E
// http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE94.html
internal func CIE94SquaredColorDifference(
    _ kL: Float = 1,
    kC: Float = 1,
    kH: Float = 1,
    K1: Float = 0.045,
    K2: Float = 0.015
    ) -> (_ lab1: LabVector, _ lab2: LabVector) -> Float {
    
    return { (lab1: LabVector, lab2: LabVector) -> Float in
        let l1 = lab1.l
        let a1 = lab1.a
        let b1 = lab1.b
        
        let l2 = lab2.l
        let a2 = lab2.a
        let b2 = lab2.b
        
        let deltaL = l1 - l2
        
        let (c1, c2) = (pythagorasC(a1, b: b1), pythagorasC(a2, b: b2))
        let deltaC = c1 - c2
        
        let deltaH = sqrt(pow(a1 - a2, 2) + pow(b1 - b2, 2) - pow(deltaC, 2))
        
        let sl: Float = 1
        let sc = 1 + K1 * c1
        let sh = 1 + K2 * c1
        
        return pow(deltaL / (kL * sl), 2) + pow(deltaC / (kC * sc), 2) + pow(deltaH / (kH * sh), 2)
    }
}

internal func CIE2000SquaredColorDifference(
    _ kL: Float = 1,
    kC: Float = 1,
    kH: Float = 1
    ) -> (_ lab1:LabVector, _ lab2:LabVector) -> Float {
    
    return { (lab1:LabVector, lab2:LabVector) -> Float in
        let l1 = lab1.l
        let a1 = lab1.a
        let b1 = lab1.b
        
        let l2 = lab2.l
        let a2 = lab2.a
        let b2 = lab2.b
        
        let deltaLp = l2 - l1
        let lbp = (l1 + l2) / 2
        
        let (c1, c2) = (pythagorasC(a1, b: b1), pythagorasC(a2, b: b2))
        let cb = (c1 + c2) / 2
        
        let G = (1 - sqrt(pow(cb, 7) / (pow(cb, 7) + pow(25, 7)))) / 2
        let ap: (Float) -> Float = { a in
            return a * (1 + G)
        }
        let (a1p, a2p) = (ap(a1), ap(a2))
        
        let (c1p, c2p) = (pythagorasC(a1p, b: b1), pythagorasC(a2p, b: b2))
        let deltaCp = c2p - c1p
        let cbp = (c1p + c2p) / 2
        
        let hp: (Float, Float) -> Float = { ap, b in
            if ap == 0 && b == 0 { return 0 }
            let theta = (atan2(b, ap)).radiansToDegrees
            return fmod(theta < 0 ? (theta + 360) : theta, 360)
        }
        let (h1p, h2p) = (hp(a1p, b1), hp(a2p, b2))
        let deltaHabs = abs(h1p - h2p)
        
        let hpDiff: Float = {
            if (c1p == 0 || c2p == 0) {
                return 0
            } else if deltaHabs <= 180 {
                return h2p - h1p
            } else if h2p <= h1p {
                return h2p - h1p + 360
            } else {
                return h2p - h1p - 360
            }
        }()
        
        let deltaHp = 2 * sqrt(c1p * c2p) * sin((hpDiff / 2).degreesToRadians)
        let hbp: Float = {
            if (c1p == 0 || c2p == 0) {
                return h1p + h2p
            } else if deltaHabs > 180 {
                return (h1p + h2p + 360) / 2
            } else {
                return (h1p + h2p) / 2
            }
        }()
        
        var t = 1
            - 0.17 * cos((hbp - 30).degreesToRadians)
            + 0.24 * cos((2 * hbp).degreesToRadians)
        
        t = t
            + 0.32 * cos((3 * hbp + 6).degreesToRadians)
            - 0.20 * cos((4 * hbp - 63).degreesToRadians)
        
        let sl = 1 + (0.015 * pow(lbp - 50, 2)) / sqrt(20 + pow(lbp - 50, 2))
        let sc = 1 + 0.045 * cbp
        let sh = 1 + 0.015 * cbp * t
        
        let deltaTheta = 30 * exp(-pow((hbp - 275) / 25, 2))
        let rc = 2 * sqrt(pow(cbp, 7) / (pow(cbp, 7) + pow(25, 7)))
        let rt = -rc * sin((2 * deltaTheta).degreesToRadians)
        
        let lTerm = deltaLp / (kL * sl)
        let cTerm = deltaCp / (kC * sc)
        let hTerm = deltaHp / (kH * sh)
        return pow(lTerm, 2) + pow(cTerm, 2) + pow(hTerm, 2) + rt * cTerm * hTerm
    }
}

