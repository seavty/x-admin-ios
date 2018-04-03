//
//  ItemCell.swift
//  X-Admin
//
//  Created by SeavTy on 12/14/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var itemGroupName: UILabel! //-> will add it in the future
    
    
    func setItem(model: ItemModel) {
        self.name.text = model.name
        self.code.text = model.code
        self.itemGroupName.text = model.itemGroup.name
    }
}
