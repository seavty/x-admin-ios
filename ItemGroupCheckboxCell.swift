//
//  ItemGroupCheckboxCell.swift
//  X-Admin
//
//  Created by SeavTy on 1/2/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class ItemGroupCheckboxCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    func setItemGroup(model: ItemGroupModel) {
        self.name.text = model.name
        
    }
    
}
