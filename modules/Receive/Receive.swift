//
//  Receive.swift
//  X-Admin
//
//  Created by SeavTy on 1/11/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class Receive: UITableViewController {

    @IBOutlet var tblReceive: UITableView!
    
    var itemModels = [ItemModel]()
    var selectIndexPath:IndexPath?
    
    var isRefresh:Bool = false
    var isEditRecord:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComp()
    }
    
    fileprivate func initComp() {
        tblReceive.dataSource = self;
        tblReceive.delegate = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(isRefresh){
            isRefresh = false
            self.tblReceive.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ReceiveCell
        
        if(itemModels.count > 0) {
            cell.setItem(model: itemModels[indexPath.row])
        }
        else {
            self.tblReceive.reloadData()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.itemModels.remove(at: indexPath.row)
            self.tblReceive.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndexPath = indexPath
        isEditRecord = true
        self.performSegue(withIdentifier: "ReceiveSummary", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "ReceiveSummary":
            let vc = segue.destination as! ReceiveSummary
            if(isEditRecord) {
                vc.isEditRecord = true
                vc.itemModel = self.itemModels[selectIndexPath!.row]
            }
        case "ReceiveSubmit":
            let vc = segue.destination as! ReceiveSubmit
            vc.itemModels = self.itemModels
            
        default:
            print("no segue")
        }
    }
    
    @IBAction func btnAdd(_ sender: UIBarButtonItem) {
        print("Add button")
        isEditRecord = false
        self.performSegue(withIdentifier: "ReceiveSummary", sender: self)
    }
    
    @IBAction func btnSubmit(_ sender: UIBarButtonItem) {
        if(self.itemModels.count == 0) {
            CustomeHelper().alertMsg(vc: self, message: "Can not submit without item")
            return
        }
        self.performSegue(withIdentifier: "ReceiveSubmit", sender: self)
    }
    
}
