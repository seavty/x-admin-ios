//
//  ItemGroupBaseDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/20/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class ItemGroupBaseDTO: Codable {
    
    var id: Int?
    var name: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int?.self, forKey: .id)
        self.name = try container.decode(String?.self, forKey: .name)
    }
    
    required init() {
        
    }
}
