//
//  ItemTableViewCell.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/19/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!
    
    @IBOutlet var lblCode: UILabel!
    
    @IBOutlet var lblItemGroup: UILabel!
    func setItem(item: ItemViewDTO) {
        lblName.text = item.name
        lblCode.text = item.code
        lblItemGroup.text = item.itemGroup?.name
    }
}
