//
//  DoubleExtension.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/21/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

extension Double {
    var toString: String {
        return String(self)
    }
    
    var to2DecimalWithDollarCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return "$ \(formatter.string(from: self as NSNumber)!)"
    }
    
    var to2Decimal: String {
        return String(format:"%.2f", self)
    }
}
