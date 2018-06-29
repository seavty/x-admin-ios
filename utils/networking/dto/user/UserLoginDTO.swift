//
//  UserLoginDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/24/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class UserLoginDTO: Codable {
    
    var userName: String?
    var password: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case userName
        case password
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userName = try container.decode(String?.self, forKey: .userName)
        self.password = try container.decode(String?.self, forKey: .password)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userName, forKey: .userName)
        try container.encode(password, forKey: .password)
    }
    
    required init() {
       
    }
}
