//
//  ItemViewDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/19/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class ItemViewDTO: ItemBaseDTO {
    
    var price: Double?
    var itemGroup: ItemGroupViewDTO?
    var documents: [DocumentViewDTO]?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case price
        case itemGroup
        case documents
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.price = try container.decode(Double?.self, forKey: .price)
        self.itemGroup = try container.decode(ItemGroupViewDTO?.self, forKey: .itemGroup)
        self.documents = try container.decode([DocumentViewDTO]?.self, forKey: .documents)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    required init() {
        super.init()
    }
}
