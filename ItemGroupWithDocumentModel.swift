//
//  ItemGroupWithDocumentModel.swift
//  X-Admin
//
//  Created by SeavTy on 1/29/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import HandyJSON

class ItemGroupWithDocumentModel : ItemGroupBase, HandyJSON{
    var documents = [DocumentModel]()
    required init() {}
}
