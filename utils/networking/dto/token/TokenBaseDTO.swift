//
//  TokenBaseDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 8/20/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class TokenBaseDTO: Codable {
    var toke_CustomerID: Int?
    var isUser: String?
    var toke_Module: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case toke_CustomerID
        case isUser
        case toke_Module
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.toke_CustomerID = try container.decode(Int?.self, forKey: .toke_CustomerID)
        self.isUser = try container.decode(String?.self, forKey: .isUser)
        self.toke_Module = try container.decode(String?.self, forKey: .toke_Module)
        
    }
    
    required init() {
        
    }
}
