//
//  CustomerViewDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/10/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
class CustomerViewDTO: CustomerBaseDTO {
    
    var code: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case code
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(String?.self, forKey: .code)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
    }
    
    
    
    //-- ** must use it, if not can not create object in CusotmerSummaryView Control ***/
    
    override required init() {
        super.init()
    }
    
    
 
}
