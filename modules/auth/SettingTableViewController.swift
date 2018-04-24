//
//  SettingTableViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/24/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    fileprivate let def = UserDefaults.standard
    
    @IBOutlet fileprivate var txtSetting: UITextField!
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }
    
    //-> saveClick
    @IBAction func saveClick(_ sender: UIBarButtonItem) {
        if isValidated() {
            self.def.set(txtSetting.text,forKey: ConstantHelper.BASE_URL);
            navigationController?.popViewController(animated: true)
        }
    }
}


//** function *** //
extension SettingTableViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
       guard let url = def.value(forKey: ConstantHelper.BASE_URL) as? String else {return}
        txtSetting.text = url
    }
    
    //-> validation
    fileprivate func isValidated() -> Bool {
        if(txtSetting.text == "") {
            self.navigationController?.view.makeToast("Setting is required", duration: 3.0, position: .center)
            return false
        }
        return true
    }
}
//*** end function ***//
