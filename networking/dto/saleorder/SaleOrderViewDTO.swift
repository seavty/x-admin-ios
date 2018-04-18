//
//  SaleOrderViewDTO
//  X-Admin
//
//  Created by BunEav Ros on 4/3/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

//class SaleOrderViewDTO : SaleOrderBase {
class SaleOrderViewDTO : SaleOrderBase {
    var saleOrderNo: String?
    var total: Double?
    var customer: CustomerViewDTO?
    
    private enum CodingKeys: String, CodingKey {
        case saleOrderNo
        case customer
        case total
    }
    
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        saleOrderNo = try container.decode(String.self, forKey: .saleOrderNo)
        total = try container.decode(Double.self, forKey: .total)
        customer = try container.decode(CustomerViewDTO.self, forKey: .customer)
        
    }
 
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(saleOrderNo, forKey: .saleOrderNo)
        try container.encode(total, forKey: .total)
    }
}

