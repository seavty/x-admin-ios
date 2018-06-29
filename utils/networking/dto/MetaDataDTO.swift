//
//  MetaDataDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/6/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class MetaDataDTO: Decodable {
    var currentPage: Int?
    var totalPage: Int?
    var totalRecord: Int?
    var pageSize: Int?
    var orderColumn: String?
    var orderBy: String?
    var search: String?
 }
