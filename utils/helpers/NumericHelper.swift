//
//  NumericHelper.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/11/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class NumericHelper {
    
    func showTwoDecimal(number: Double) -> String {
        let doubleValue : Double = number
        return "$ \(String(format:"%.2f", doubleValue))"
        
    }
}
