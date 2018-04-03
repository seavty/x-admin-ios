//
//  ReceiveCell.swift
//  X-Admin
//
//  Created by SeavTy on 1/11/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class ReceiveCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    func setItem(model: ItemModel) {
        self.name.text = model.name
        self.code.text = model.code
        self.quantity.text = String(model.quantity)
        //self.cost.text = String(model.cost)
        self.cost.text = CustomeHelper().showTwoDecimal(number: model.cost)
        
    }
}
