//
//  UIColor+colorDiff.swift
//  Lorikeet
//
//  Created by Þorvaldur Rúnarsson on 28/10/2017.
//  Copyright © 2017 Thorvaldur. All rights reserved.
//

import UIKit

public extension UIColor {
    public var lkt: Lorikeet {
        return Lorikeet(self)
    }
}
