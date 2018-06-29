//
//  ItemGroupUploadImagesDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/26/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class ItemGroupUploadImagesDTO : Codable {
    
    var id: Int?
    var base64s: [String]?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case base64s
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int?.self, forKey: .id)
        self.base64s = try container.decode([String]?.self, forKey: .base64s)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(base64s, forKey: .base64s)
    }
    
    required init() {
        
    }
}
