//
//  ItemGroupCell.swift
//  X-Admin
//
//  Created by SeavTy on 12/15/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit

class ItemGroupCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    func setItemGroup(model: ItemGroupWithDocumentModel) {
        self.name.text = model.name
        
    }
   
}
