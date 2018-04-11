//
//  SaleOrderListDTO.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/6/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class SaleOrderListDTO: Decodable {
    var metaData: MetaDataDTO?
    var results: [SaleOrderViewDTO]?
}
