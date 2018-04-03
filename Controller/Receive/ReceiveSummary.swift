//
//  ReceiveSummary.swift
//  X-Admin
//
//  Created by SeavTy on 1/11/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ReceiveSummary: UITableViewController {

    //var baseURL = Server().apiURL + "items/"
    var baseURL = CustomeHelper().apiURL() + "items/"
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtQuantity: UITextField!
    @IBOutlet weak var txtCost: UITextField!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    var itemModel = ItemModel()
    var isRefresh:Bool = false
    var isEditRecord:Bool = false
    
    var isFromIssueVC: Bool = false
    //var itemModels = [ItemModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComp()
        
        if(isEditRecord == false) {
            btnSave.title = "Save & New"
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshData()
    }
    
    fileprivate func initComp() {
        txtName.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        disableControl()
        
        txtName.text! = itemModel.name
        txtCode.text! = itemModel.code
        txtQuantity.text! = String(itemModel.quantity)
        txtCost.text! = String(itemModel.cost)
    }
    
    @objc func myTargetFunction() {
        print("It works!")
        self.performSegue(withIdentifier: "SearchItem", sender: self)
    }

    @IBAction func btnSave(_ sender: UIBarButtonItem) {
        if (validation() == false) {
            return;
        }
        
        itemModel.quantity = (txtQuantity.text! as NSString).integerValue
        itemModel.cost = (txtCost.text! as NSString).doubleValue
        
        //-- need remmove these redundant code letter
        if(isFromIssueVC) {
            guard let vc = self.navigationController!.viewControllers[0] as? Issue else { return }
            if(btnSave.title == "Save") {
                vc.isRefresh = true
                self.navigationController?.popToViewController(vc, animated: true)
            }
            else {
                vc.itemModels.append(itemModel)
                clearData();
            }
            
        }
        else {
            guard let vc = self.navigationController!.viewControllers[0] as? Receive else { return }
            if(btnSave.title == "Save") {
                vc.isRefresh = true
                self.navigationController?.popToViewController(vc, animated: true)
            }
            else {
                vc.itemModels.append(itemModel)
                clearData();
            }
        }
    }
    
    @IBAction func btnDone(_ sender: UIBarButtonItem) {
       //--repeat / redundancy code // -- will check it in the future
        if(isFromIssueVC) {
            guard let vc = self.navigationController!.viewControllers[0] as? Issue else { return }
            vc.isRefresh = true
            self.navigationController?.popToViewController(vc, animated: true)
        }
        else {
            guard let vc = self.navigationController!.viewControllers[0] as? Receive else { return }
            vc.isRefresh = true
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
    
    fileprivate func refreshData() {
        if(isRefresh){
            isRefresh = false
            
            txtName.text! = self.itemModel.name
            txtCode.text! = self.itemModel.code
        }
    }
    
    fileprivate func validation() -> Bool {
        //-- tap to get item -> user not allow to type item name 
        if (itemModel.id  == "") {
            CustomeHelper().alertMsg(vc: self, message: "Item is required")
            return false
        }
        
        if (txtQuantity.text  == "") {
            CustomeHelper().alertMsg(vc: self, message: "Quantity is required")
            return false
        }
        
        if (txtCost.text  == "") {
            CustomeHelper().alertMsg(vc: self, message: "Cost is required")
            return false
        }
        return true
    }
    
    fileprivate func disableControl() {
        self.txtCode.isEnabled = false
    }
    
    fileprivate func clearData() {
        self.itemModel = ItemModel()
        txtName.text! = self.itemModel.name
        txtCode.text! = self.itemModel.code
        txtQuantity.text! = String(self.itemModel.quantity)
        txtCost.text! = String(self.itemModel.cost)
    }
}
