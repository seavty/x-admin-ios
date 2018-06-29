//
//  DocumentViewDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/25/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class DocumentViewDTO: Codable {
    
    var id: Int?
    var name: String?
    var path: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case name
        case path
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int?.self, forKey: .id)
        self.name = try container.decode(String?.self, forKey: .name)
        self.path = try container.decode(String?.self, forKey: .path)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(path, forKey: .path)
    }
    
    required init() {
        
    }
}
