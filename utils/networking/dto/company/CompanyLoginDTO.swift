//
//  CustomerLoginDTO.swift
//  X-Admin
//
//  Created by SeavTy on 8/5/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class CompanyLoginDTO: Codable {
    
    var user_UserName: String?
    var user_Password: String?
    var user_DB : String?
    var user_StoreName : String?
    //var user_userid : Int?
    
    fileprivate enum CodingKeys: String, CodingKey {
        case user_UserName
        case user_Password
        case user_DB
        case user_StoreName
        //case user_userid
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_UserName = try container.decode(String?.self, forKey: .user_UserName)
        self.user_Password = try container.decode(String?.self, forKey: .user_Password)
        self.user_DB = try container.decode(String?.self, forKey: .user_DB)
        self.user_StoreName = try container.decode(String?.self, forKey: .user_StoreName)
        //self.user_userid = try container.decode(Int?.self, forKey: .user_userid)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user_UserName, forKey: .user_UserName)
        try container.encode(user_Password, forKey: .user_Password)
        try container.encode(user_DB, forKey: .user_DB)
        try container.encode(user_StoreName, forKey: .user_StoreName)
        //try container.encode(user_userid, forKey: .user_userid)
    }
    
    required init() {
        
    }
}
