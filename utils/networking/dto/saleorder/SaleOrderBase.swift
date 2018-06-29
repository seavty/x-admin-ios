//
//  SaleOrderBase.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/3/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

//class SaleOrderBase: Decodable {
class SaleOrderBase : Codable {
    var id: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
    }
    
    /*
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
    }
    */
}

