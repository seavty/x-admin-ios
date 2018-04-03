//
//  Issue.swift
//  X-Admin
//
//  Created by SeavTy on 1/12/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class Issue: UITableViewController {

    @IBOutlet var tblIssue: UITableView!
    
    var itemModels = [ItemModel]()
    var selectIndexPath:IndexPath?
    
    var isRefresh:Bool = false
    var isEditRecord:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         initComp()
    }

    func initComp() {
        tblIssue.dataSource = self;
        tblIssue.delegate = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(isRefresh){
            isRefresh = false
            self.tblIssue.reloadData()
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemModels.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! IssueCell
        
        if(itemModels.count > 0) {
            cell.setItem(model: itemModels[indexPath.row])
        }
        else {
            self.tblIssue.reloadData()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.itemModels.remove(at: indexPath.row)
            self.tblIssue.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndexPath = indexPath
        isEditRecord = true
        self.performSegue(withIdentifier: "IssueSummary", sender: self)
        
    }
    
    
    @IBAction func btnAdd(_ sender: UIBarButtonItem) {
        print("Add button")
        isEditRecord = false
        self.performSegue(withIdentifier: "IssueSummary", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "IssueSummary":
            print("go to IssueSummary")
            let vc = segue.destination as! ReceiveSummary
            vc.isFromIssueVC = true
            if(isEditRecord) {
                vc.isEditRecord = true
                vc.itemModel = self.itemModels[selectIndexPath!.row]
            }
            
        case "Submit":
            let vc = segue.destination as! ReceiveSubmit
            vc.itemModels = self.itemModels
            vc.isFromIssueVC = true
            
        default:
            print("no segue")
        }
    }
    
    
    @IBAction func btnSumbit(_ sender: UIBarButtonItem) {
        if(self.itemModels.count == 0) {
            CustomeHelper().alertMsg(vc: self, message: "Can not submit without item")
            return
        }
        self.performSegue(withIdentifier: "Submit", sender: self)
    }
    
    
}

