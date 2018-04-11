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
    
    private enum CodingKeys: String, CodingKey {
        case code
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(String.self, forKey: .code)
        try super.init(from: decoder)
    }
}
