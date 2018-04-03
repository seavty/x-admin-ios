//
//  ReceiveIssueModel.swift
//  X-Admin
//
//  Created by SeavTy on 1/12/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import HandyJSON

class ReceiveIssueModel : HandyJSON      {
    
    var warehouseID: Int = 0
    var remarks: String = ""
    
    var items = [ItemModel]()
    
    required init() {}
}
