//
//  HomeViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/26/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //-> logoutClick
    @IBAction func logoutClick(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "System", message: "Do you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.handleLogout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//*** function ***/
extension HomeViewController {
    
    //-> handleLogout
    fileprivate func handleLogout() {
        let storyboard = UIStoryboard(name: ConstantHelper.MAIN_STRORYBOARD, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: ConstantHelper.LOGIN_CONTROLLER)
        self.present(controller, animated: true, completion: nil)
    }
}
//*** end function  ***/
