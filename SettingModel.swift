//
//  SettingModel.swift
//  X-Admin
//
//  Created by SeavTy on 1/12/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import HandyJSON

class SettingModel : HandyJSON {
    
    var id: Int = 0
    var customer = CustomerModel()
    var warehouse = WarehouseModel()
    required init() {}
}
