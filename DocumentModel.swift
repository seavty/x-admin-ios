//
//  DocumentModel.swift
//  X-Admin
//
//  Created by SeavTy on 1/22/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import HandyJSON

class DocumentModel : HandyJSON {
    
    var id: Int = 0
    var name = ""
    var path = ""
    required init() {}
}
