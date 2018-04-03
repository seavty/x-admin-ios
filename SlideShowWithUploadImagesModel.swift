//
//  SlideShowWithUploadImagesModel.swift
//  X-Admin
//
//  Created by SeavTy on 1/31/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import HandyJSON

class SlideShowWithUploadImagesModel : HandyJSON {
    var id: Int = 0
    var images = [String]()
    required init() {}
}
