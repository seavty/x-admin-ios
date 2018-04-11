//
//  SaleOrderViewDTO
//  X-Admin
//
//  Created by BunEav Ros on 4/3/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.saleOrderNo = try container.decode(String.self, forKey: .saleOrderNo)
        self.total = try container.decode(Double.self, forKey: .total)
        self.customer = try container.decode(CustomerViewDTO.self, forKey: .customer)
        try super.init(from: decoder)
    }
}
