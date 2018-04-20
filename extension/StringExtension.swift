//
//  StringExtension.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/20/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

extension String {
    var toDouble: Double {
        return Double(self) ?? 0.0
    }
}
