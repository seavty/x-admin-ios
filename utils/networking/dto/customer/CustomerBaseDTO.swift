//
//  CustomerBaseDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/10/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class CustomerBaseDTO: Codable {
    var id: Int?
    var name: String?
    var phone: String?
    var address: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case address
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int?.self, forKey: .id)
        self.name = try container.decode(String?.self, forKey: .name)
        self.phone = try container.decode(String?.self, forKey: .phone)
        self.address = try container.decode(String?.self, forKey: .address)
    }
    
    required init() {
        
    }
}
