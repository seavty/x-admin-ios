//
//  ItemGroupTableViewCell.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/20/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class ItemGroupTableViewCell: UITableViewCell {

   @IBOutlet var lblName: UILabel!
    
    func setItemGroup(itemGroup: ItemGroupViewDTO) {
        lblName.text = itemGroup.name
    }
    
}
