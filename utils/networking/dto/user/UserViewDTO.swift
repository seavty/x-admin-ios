//
//  UserViewDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/24/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class UserViewDTO: Codable {
    
    var userProfile: UserProfileViewDTO?
    var token: String?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case userProfile
        case token
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userProfile = try container.decode(UserProfileViewDTO?.self, forKey: .userProfile)
        self.token = try container.decode(String?.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userProfile, forKey: .userProfile)
        try container.encode(token, forKey: .token)
    }
    
    
    required init() {
    }
}

