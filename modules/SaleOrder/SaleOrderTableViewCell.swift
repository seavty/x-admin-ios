//
//  SaleOrderTableViewCell.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/3/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class SaleOrderTableViewCell: UITableViewCell {

    @IBOutlet var lblSaleOrderNo: UILabel!
    @IBOutlet var lblTotal: UILabel!
    @IBOutlet var lblCustomerName: UILabel!
    
    func setSaleOrder(saleOrder: SaleOrderViewDTO) {
        self.lblSaleOrderNo.text = saleOrder.saleOrderNo
        self.lblTotal.text = NumericHelper().showTwoDecimal(number: saleOrder.total ?? 0.0)
        self.lblCustomerName.text = saleOrder.customer?.name
    }
}
