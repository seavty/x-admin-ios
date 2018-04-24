//
//  ItemTableViewCellForDataSource.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/21/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//


import UIKit

class ItemTableViewCellForDataSource: UITableViewCell {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblCode: UILabel!
    @IBOutlet var lblQuantity: UILabel!
    @IBOutlet var lblCost: UILabel!
    
    func setReceiveItem(receiveItem: ReceiveItemNewDTO, isIssueModule:Bool=false) {
        lblName.text = receiveItem.name
        lblCode.text = receiveItem.code
        lblQuantity.text = receiveItem.quantity?.toString
        lblCost.text = receiveItem.cost?.to2DecimalWithDollarCurrency
        
        if isIssueModule {
            lblQuantity.textColor = UIColor.red
            lblCost.textColor = UIColor.red
        }
        else {
            lblQuantity.textColor = UIColor.blue
            lblCost.textColor = UIColor.blue
        }
    }
}
