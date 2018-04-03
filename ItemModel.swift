//
//  ItemModel.swift
//  X-Admin
//
//  Created by SeavTy on 12/14/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import Foundation
import HandyJSON

class ItemModel : HandyJSON {
    
    // will need to make ItemModel inherit from ItemBase
    // should create class ItemWithPriceModel -> have price property
    // should create class ItemWithCostModel -> have quantity ,  cost as property
    
    var id: String = ""
    var code: String = ""
    var name: String = ""
    var description: String = ""
    var quantity: Int = 0
    var price: Double = 0.0
    var cost: Double = 0.0
    var itemGroup = ItemGroupModel()
    var images = [String]()
    var documents = [DocumentModel]()
    required init() {}
    //override required init() {}
    
    
    
}
