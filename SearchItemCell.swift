//
//  SearchItemCell.swift
//  X-Admin
//
//  Created by SeavTy on 1/11/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class SearchItemCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var itemGroupName: UILabel!
    
    func setItem(model: ItemModel) {
        self.name.text = model.name
        self.code.text = model.code
        self.itemGroupName.text = model.itemGroup.name
    }
}
