//
//  ItemEditDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/20/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class ItemEditDTO: ItemBaseDTO {
    
    var price: Double?
    var itemGroup: ItemGroupViewDTO?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case price
        case itemGroup
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.price = try container.decode(Double?.self, forKey: .price)
        self.itemGroup = try container.decode(ItemGroupViewDTO?.self, forKey: .itemGroup)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(price, forKey: .price)
        try container.encode(itemGroup, forKey: .itemGroup )
        
    }
    
    required init() {
        super.init()
    }
    
}
