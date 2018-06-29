//
//  ItemGroupViewDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/20/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class ItemGroupViewDTO: ItemGroupBaseDTO {
    
    var documents: [DocumentViewDTO]?
    
    
    fileprivate enum CodingKeys: String, CodingKey {
        case documents
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.documents = try container.decode([DocumentViewDTO]?.self, forKey: .documents)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    required init() {
        super.init()
    }
    
}
