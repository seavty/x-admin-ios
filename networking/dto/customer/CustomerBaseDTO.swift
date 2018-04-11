//
//  CustomerBaseDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/10/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
class CustomerBaseDTO: Decodable {
    var id: Int?
    var name: String?
    var phone: String?
    var address: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case address
    }
}
