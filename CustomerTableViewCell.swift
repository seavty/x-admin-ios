//
//  CustomerTableViewCell.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/15/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class CustomerTableViewCell: UITableViewCell {

    @IBOutlet var lblCustomerName: UILabel!
    @IBOutlet var lblPhoneNumber: UILabel!
    
    func setCustomer(customer: CustomerViewDTO) {
        lblCustomerName.text = customer.name
        lblPhoneNumber.text = customer.phone
    }
}
