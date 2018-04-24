//
//  SettingViewDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/24/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class SettingViewDTO : Codable {
    
    var id: Int?
    var customer: CustomerViewDTO?
    var warehouse: WarehouseViewDTO?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case customer
        case warehouse
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int?.self, forKey: .id)
        self.customer = try container.decode(CustomerViewDTO?.self, forKey: .customer)
        self.warehouse = try container.decode(WarehouseViewDTO?.self, forKey: .warehouse)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(warehouse, forKey: .warehouse)
    }
    
    required init() {
    
    }
}
