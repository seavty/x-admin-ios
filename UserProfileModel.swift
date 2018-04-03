//
//  UserProfileModel.swift
//  X-Admin
//
//  Created by SeavTy on 1/16/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import HandyJSON

class UserProfileModel : HandyJSON {
    var id: Int = 0
    var userName: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var gender: String = ""
    var token: String = ""
    
    var setting = SettingModel()
    
    required init() {}
}
