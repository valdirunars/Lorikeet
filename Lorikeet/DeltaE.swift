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

/// From http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE76.html
internal func CIE76SquaredColorDifference(lab1: LabVector, lab2: LabVector) -> Float {
    let l1 = lab1.l
    let a1 = lab1.a
    let b1 = lab1.b
    
    let l2 = lab2.l
    let a2 = lab2.a
    let b2 = lab2.b
    
    return pow(l2 - l1, 2) + pow(a2 - a1, 2) + pow(b2 - b1, 2)
}

private func pythagorasC(a: Float, b: Float) -> Float {
    return sqrt(pow(a, 2) + pow(b, 2))
}

/// Swiftified version of Bruce Lindbloom's math equation for Delta E
/// http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE94.html
internal func CIE94SquaredColorDifference(
    kL: Float = 1,
    kC: Float = 1,
    kH: Float = 1,
    k1: Float = 0.045,
    k2: Float = 0.015
    ) -> (_ lab1: LabVector, _ lab2: LabVector) -> Float {
    
    return { (lab1: LabVector, lab2: LabVector) -> Float in
        let l1 = lab1.l
        let a1 = lab1.a
        let b1 = lab1.b
        
        let l2 = lab2.l
        let a2 = lab2.a
        let b2 = lab2.b
        
        let deltaL = l1 - l2
        
        let (c1, c2) = (pythagorasC(a: a1, b: b1), pythagorasC(a: a2, b: b2))
        let deltaC = c1 - c2
        
        let deltaH = sqrt(pow(a1 - a2, 2) + pow(b1 - b2, 2) - pow(deltaC, 2))
        
        let sl: Float = 1
        let sc = 1 + k1 * c1
        let sh = 1 + k2 * c1
        
        return pow(deltaL / (kL * sl), 2) + pow(deltaC / (kC * sc), 2) + pow(deltaH / (kH * sh), 2)
    }
}

internal func CIE2000SquaredColorDifference(
    kL: Float = 1,
    kC: Float = 1,
    kH: Float = 1
    ) -> (_ lab1: LabVector, _ lab2: LabVector) -> Float {
    
    return { (lab1: LabVector, lab2: LabVector) -> Float in
        // some utils
        let zero: Float = 0
        let one: Float = 1
        let two: Float = 2
        let seven: Float = 7
        let twentyFive: Float = 25
        let oneEighty: Float = 180
        let threeSixty: Float = 360
        
        let l1 = lab1.l
        let a1 = lab1.a
        let b1 = lab1.b
        
        let l2 = lab2.l
        let a2 = lab2.a
        let b2 = lab2.b
        
        let deltaLp = l2 - l1
        let lbp = (l1 + l2) / two
        
        let (c1, c2) = (pythagorasC(a: a1, b: b1), pythagorasC(a: a2, b: b2))
        let cb = (c1 + c2) / two
        
        let G = (one - sqrt(pow(cb, seven) / (pow(cb, seven) + pow(twentyFive, seven)))) / two
        let ap: (Float) -> Float = { a in
            return a * (one + G)
        }
        let (a1p, a2p) = (ap(a1), ap(a2))
        
        let (c1p, c2p) = (pythagorasC(a: a1p, b: b1), pythagorasC(a: a2p, b: b2))
        let deltaCp = c2p - c1p
        let cbp = (c1p + c2p) / two
        
        let hp: (Float, Float) -> Float = { ap, b -> Float in
            if ap == zero && b == zero { return zero }
            let theta = (atan2(b, ap)).radiansToDegrees
            return fmod(theta < zero ? (theta + threeSixty) : theta, threeSixty)
        }
        let (h1p, h2p) = (hp(a1p, b1), hp(a2p, b2))
        let deltaHabs = abs(h1p - h2p)
        
        let hpDiff: Float = {
            if (c1p == zero || c2p == zero) {
                return zero
            } else if deltaHabs <= oneEighty {
                return h2p - h1p
            } else if h2p <= h1p {
                return h2p - h1p + threeSixty
            } else {
                return h2p - h1p - threeSixty
            }
        }()
        
        let deltaHp = two * sqrt(c1p * c2p) * sin((hpDiff / two).degreesToRadians)
        let hbp: Float = {
            if (c1p == zero || c2p == zero) {
                return h1p + h2p
            } else if deltaHabs > oneEighty {
                return (h1p + h2p + threeSixty) / two
            } else {
                return (h1p + h2p) / two
            }
        }()
        
        var t = one
            - 0.17 * cos((hbp - 30).degreesToRadians)
            + 0.24 * cos((two * hbp).degreesToRadians)
        
        t = t
            + 0.32 * cos((3 * hbp + 6).degreesToRadians)
            - 0.20 * cos((4 * hbp - 63).degreesToRadians)
        
        let sl = one + (0.015 * pow(lbp - 50, two)) / sqrt(20 + pow(lbp - 50, two))
        let sc = one + 0.045 * cbp
        let sh = one + 0.015 * cbp * t
        
        let deltaTheta = 30 * exp(-pow((hbp - 275) / twentyFive, two))
        let rc = two * sqrt(pow(cbp, seven) / (pow(cbp, seven) + pow(twentyFive, seven)))
        let rt = -rc * sin((two * deltaTheta).degreesToRadians)
        
        let lTerm = deltaLp / (kL * sl)
        let cTerm = deltaCp / (kC * sc)
        let hTerm = deltaHp / (kH * sh)
        return pow(lTerm, two) + pow(cTerm, two) + pow(hTerm, two) + rt * cTerm * hTerm
    }
}

