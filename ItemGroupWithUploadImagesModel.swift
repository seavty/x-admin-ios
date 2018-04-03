//
//  ItemGroupWithUploadImagesModel.swift
//  X-Admin
//
//  Created by SeavTy on 1/29/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import HandyJSON

class ItemGroupWithUploadImagesModel : ItemGroupBase, HandyJSON  {
    var images = [String]()
    //override required init() {}
    required init() {}
}
