//
//  WarehouseModel.swift
//  X-Admin
//
//  Created by SeavTy on 1/16/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import HandyJSON

class WarehouseModel : HandyJSON {
    var id: Int = 0
    var name: String = ""
    var address: String = ""
    required init() {}
}
