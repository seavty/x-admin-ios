//
//  Home.swift
//  X-Admin
//
//  Created by SeavTy on 11/27/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit

class Home: UITableViewController {

    @IBOutlet weak var btMenuDrawer: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sideMenus()
    {
        if revealViewController() != nil
        {
            btMenuDrawer.target = revealViewController();
            btMenuDrawer.action = #selector(SWRevealViewController.revealToggle(_:)); // or "revealToggle";
            revealViewController().rearViewRevealWidth = 275;
            revealViewController().rightViewRevealWidth = 160;
            
            //btMenuDrawer.action = #selector(SWRevealViewController.rightRevealToggle(_:));
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //print("EmployeeInfo")
    }
}
