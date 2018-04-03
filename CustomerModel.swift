//
//  CustomerModel.swift
//  X-Admin
//
//  Created by SeavTy on 12/5/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import Foundation
import HandyJSON

class CustomerModel : HandyJSON {
 
    var id: String = ""
    var name: String = ""
    var code: String = ""
    var phone: String = ""
    var address: String = ""
    
    required init() {}
}
