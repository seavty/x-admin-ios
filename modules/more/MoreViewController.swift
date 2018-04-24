//
//  MoreViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/23/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    struct StoryboardInfo {
        static let recevieSegue = "ReceiveSegue"
        static let issueSegue = "IssueSegue"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case StoryboardInfo.issueSegue?:
            guard let vc = segue.destination as? ReceiveTableViewController else {return}
            vc.isIssueModule = true
        default:
            print("no segue")
        }
    }
    
    

}
