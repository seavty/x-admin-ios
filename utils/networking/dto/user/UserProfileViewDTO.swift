//
//  UserProfileDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/24/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class UserProfileViewDTO: Codable {
    
    var id: Int?
    var userName: String?
    var firstName: String?
    var lastName: String?
    var gender: String?
    var setting: SettingViewDTO?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case userName
        case firstName
        case lastName
        case gender
        case setting
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int?.self, forKey: .id)
        self.userName = try container.decode(String?.self, forKey: .userName)
        self.firstName = try container.decode(String?.self, forKey: .firstName)
        self.lastName = try container.decode(String?.self, forKey: .lastName)
        self.gender = try container.decode(String?.self, forKey: .gender)
        self.setting = try container.decode(SettingViewDTO?.self, forKey: .setting)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userName, forKey: .userName)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(gender, forKey: .gender)
        try container.encode(setting, forKey: .setting)
    }
    
    required init() {
    }
}

