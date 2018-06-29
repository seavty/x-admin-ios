//
//  ReceiveItemNewDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/21/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class ReceiveItemNewDTO: ItemBaseDTO {
    
    var quantity: Int?
    var cost: Double?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case quantity
        case cost
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.quantity = try container.decode(Int?.self, forKey: .quantity)
        self.cost = try container.decode(Double?.self, forKey: .cost)
        
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(cost, forKey: .cost)
    }
    
    required init() {
        super.init()
    }
}
