//
//  CustomerCell.swift
//  X-Admin
//
//  Created by SeavTy on 11/27/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {

    
    @IBOutlet weak var lblCustomerName: UILabel!

    @IBOutlet weak var lblPhoneNumber: UILabel!
    
    func setCustomer(model: CustomerModel) {
        self.lblCustomerName.text = model.name
        self.lblPhoneNumber.text = model.phone
    }
}
