//
//  Setting.swift
//  X-Admin
//
//  Created by SeavTy on 1/19/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class Setting: UITableViewController {
    let def = UserDefaults.standard;
    @IBOutlet weak var txtIP: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        if def.value(forKey: "IP") != nil {
            txtIP.text = def.value(forKey: "IP") as! String?
        }
    }

    
    @IBAction func btnSave(_ sender: UIButton) {
        
        if(txtIP.text  == "") {
            CustomeHelper().alertMsg(vc: self, message: "IP address is required")
        }
        else {
            self.def.set(txtIP.text,forKey: "IP");
            //perform segue
            
            performSegue(withIdentifier: "Auth", sender: self)
        }
    }
    
}
