//
//  ErrorDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/18/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class ErrorDTO : Codable {
    var message: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case message = "Message"
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        
    }
}
