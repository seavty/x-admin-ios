//
//  CustomerEditDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/18/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class CustomerEditDTO : CustomerBaseDTO {
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    /*
    override required init() {
        super.init()
    }
    */
    
    required init() {
        super.init()
    }
}
