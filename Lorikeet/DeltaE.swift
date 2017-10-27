//
//  DeltaE.swift
//  Lorikeet
//
//  Created by Þorvaldur Rúnarsson on 27/10/2017.
//  Copyright © 2017 Thorvaldur. All rights reserved.
//

import Foundation

extension Float {
    var degreesToRadians: Float { return Float(self) * .pi / 180 }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

typealias LabVector = (l: Float, a: Float, b: Float)

// From http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE76.html
func CIE76SquaredColorDifference(_ lab1: LabVector, lab2: LabVector) -> Float {
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
func CIE94SquaredColorDifference(
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
        
        let (C1, C2) = (pythagorasC(a1, b: b1), pythagorasC(a2, b: b2))
        let deltaC = C1 - C2
        
        let deltaH = sqrt(pow(a1 - a2, 2) + pow(b1 - b2, 2) - pow(deltaC, 2))
        
        let Sl: Float = 1
        let Sc = 1 + K1 * C1
        let Sh = 1 + K2 * C1
        
        return pow(deltaL / (kL * Sl), 2) + pow(deltaC / (kC * Sc), 2) + pow(deltaH / (kH * Sh), 2)
    }
}

func CIE2000SquaredColorDifference(
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
        let Lbp = (l1 + l2) / 2
        
        let (C1, C2) = (pythagorasC(a1, b: b1), pythagorasC(a2, b: b2))
        let Cb = (C1 + C2) / 2
        
        let G = (1 - sqrt(pow(Cb, 7) / (pow(Cb, 7) + pow(25, 7)))) / 2
        let ap: (Float) -> Float = { a in
            return a * (1 + G)
        }
        let (a1p, a2p) = (ap(a1), ap(a2))
        
        let (C1p, C2p) = (pythagorasC(a1p, b: b1), pythagorasC(a2p, b: b2))
        let deltaCp = C2p - C1p
        let Cbp = (C1p + C2p) / 2
        
        let hp: (Float, Float) -> Float = { ap, b in
            if ap == 0 && b == 0 { return 0 }
            let θ = (atan2(b, ap)).radiansToDegrees
            return fmod(θ < 0 ? (θ + 360) : θ, 360)
        }
        let (h1p, h2p) = (hp(a1p, b1), hp(a2p, b2))
        let deltaHabs = abs(h1p - h2p)
        
        let hpDiff: Float = {
            if (C1p == 0 || C2p == 0) {
                return 0
            } else if deltaHabs <= 180 {
                return h2p - h1p
            } else if h2p <= h1p {
                return h2p - h1p + 360
            } else {
                return h2p - h1p - 360
            }
        }()
        
        let deltaHp = 2 * sqrt(C1p * C2p) * sin((hpDiff / 2).degreesToRadians)
        let Hbp: Float = {
            if (C1p == 0 || C2p == 0) {
                return h1p + h2p
            } else if deltaHabs > 180 {
                return (h1p + h2p + 360) / 2
            } else {
                return (h1p + h2p) / 2
            }
        }()
        
        var t = 1
            - 0.17 * cos((Hbp - 30).degreesToRadians)
            + 0.24 * cos((2 * Hbp).degreesToRadians)
        
        t = t
            + 0.32 * cos((3 * Hbp + 6).degreesToRadians)
            - 0.20 * cos((4 * Hbp - 63).degreesToRadians)
        
        let Sl = 1 + (0.015 * pow(Lbp - 50, 2)) / sqrt(20 + pow(Lbp - 50, 2))
        let Sc = 1 + 0.045 * Cbp
        let Sh = 1 + 0.015 * Cbp * t
        
        let deltaTheta = 30 * exp(-pow((Hbp - 275) / 25, 2))
        let Rc = 2 * sqrt(pow(Cbp, 7) / (pow(Cbp, 7) + pow(25, 7)))
        let Rt = -Rc * sin((2 * deltaTheta).degreesToRadians)
        
        let Lterm = deltaLp / (kL * Sl)
        let Cterm = deltaCp / (kC * Sc)
        let Hterm = deltaHp / (kH * Sh)
        return pow(Lterm, 2) + pow(Cterm, 2) + pow(Hterm, 2) + Rt * Cterm * Hterm
    }
}

