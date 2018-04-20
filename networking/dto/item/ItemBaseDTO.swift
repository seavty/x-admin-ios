//
//  ItemBaseDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/19/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class ItemBaseDTO: Codable {
    var id: Int?
    var code: String?
    var name: String?
    var description: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case code
        case name
        case description
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int?.self, forKey: .id)
        self.code = try container.decode(String?.self, forKey: .code)
        self.name = try container.decode(String?.self, forKey: .name)
        self.description = try container.decode(String?.self, forKey: .description)
    }
    
    required init() {
        
    }
}
