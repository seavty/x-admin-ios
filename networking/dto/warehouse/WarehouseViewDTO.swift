//
//  WarehouseViewDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/24/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class WarehouseViewDTO: Codable {
    
    var id: Int?
    var name: String?
    var address: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int?.self, forKey: .id)
        self.name = try container.decode(String?.self, forKey: .name)
        self.address = try container.decode(String?.self, forKey: .address)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
    }
    
    required init() {
    }
}
