//
//  CustomerSummary.swift
//  X-Admin
//
//  Created by SeavTy on 11/28/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CustomerSummary: UITableViewController {
    
    //var baseURL = Server().apiURL + "customers/"
    var baseURL = CustomeHelper().apiURL() + "customers/"
    
    @IBOutlet weak var txtCustomerName: UITextField!
    @IBOutlet weak var txtCustomerCode: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtAddress: UITextView!
    @IBOutlet weak var barItem: UIBarButtonItem!
    
    
    var customerModel = CustomerModel()
    
    //----------- *** ------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComp()
    }
    
    fileprivate func initComp() {
        barItem.title = "Edit"
        if(customerModel.id == "") {
            barItem.title = "Save"
        }
        else {
            loadSummary()
        }
    }
    
    @IBAction func barItemClick(_ sender: UIBarButtonItem) {
       if barItem.title == "Save" {
            if (customerModel.id == "") {
                newRecord()
            }
            else {
                updateRecord()
            }
        }
        barItem.title = "Save"
        enableControl()
    }
    
    // *** crud operation ** //
    
    //-- create
    fileprivate func newRecord() {
        if (validation() == false) {
            return;
        }
        
        let model = CustomerModel();
        model.name = txtCustomerName.text!
        model.phone = txtPhoneNumber.text!
        model.address = txtAddress.text!
        
        var request = CustomeHelper().getRequestHeader(url: baseURL, method: RequestMethod.post)
        let json = model.toJSONString()!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            (response) in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                if let vc = self.navigationController!.viewControllers[0] as? Customer {
                    vc.isRefresh = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
    
    //-- read
    fileprivate func loadSummary() {
        disableControl()
        
        let url = baseURL + customerModel.id
        let request = CustomeHelper().getRequestHeader(url: url, method: RequestMethod.get)
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            response in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                let json = JSON(response.result.value!)
                self.txtCustomerName.text = json["name"].stringValue
                self.txtCustomerCode.text = json["code"].stringValue
                self.txtPhoneNumber.text = json["phone"].stringValue
                self.txtAddress.text = json["address"].stringValue
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
    
    //-- update
    fileprivate func updateRecord() {
        
        //create new record & update record code similar need to refactor it
        if (validation() == false) {
            return;
        }
        
        let model = CustomerModel();
        model.id = customerModel.id
        model.name = txtCustomerName.text!
        model.phone = txtPhoneNumber.text!
        model.address = txtAddress.text!
        
        let url = baseURL + model.id
        var request = CustomeHelper().getRequestHeader(url: url, method: RequestMethod.put)
        let json = model.toJSONString()!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            (response) in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                if let vc = self.navigationController!.viewControllers[0] as? Customer {
                    vc.isRefresh = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
    
    // *** end  crud operation ** //
    
    fileprivate func validation() -> Bool {
        if (txtCustomerName.text  == "") {
            CustomeHelper().alertMsg(vc: self, message: "Customer Name is required")
            return false
        }
        
        if (txtPhoneNumber.text  == "") {
            CustomeHelper().alertMsg(vc: self, message: "Phone number is required")
            return false
        }
        
        if (txtPhoneNumber.text!.count < 9) {
            CustomeHelper().alertMsg(vc: self, message: "Phone number must be at least 9 characters")
            return false
        }
        
        if (txtPhoneNumber.text!.count > 50) {
            CustomeHelper().alertMsg(vc: self, message: "Phone number can not greater than 50 characters")
            return false
        }
        
        return true
    }
    
    fileprivate func disableControl() {
        self.txtCustomerName.isEnabled = false
        self.txtPhoneNumber.isEnabled = false
        self.txtAddress.isEditable = false
        
    }
    
    fileprivate func enableControl() {
        self.txtCustomerName.isEnabled = true
        self.txtPhoneNumber.isEnabled = true
        self.txtAddress.isEditable = true
    }

}
