//
//  IssueItemNewDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/23/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class IssueItemNewDTO: ItemBaseDTO {
    
    var quantity: Int?
    var price: Double?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case quantity
        case price
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.quantity = try container.decode(Int?.self, forKey: .quantity)
        self.price = try container.decode(Double?.self, forKey: .price)
        
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(price, forKey: .price)
    }
    
    required init() {
        super.init()
    }
}
