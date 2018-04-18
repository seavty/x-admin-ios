//
//  CustomerSummaryTableViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/16/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class CustomerSummaryTableViewController: UITableViewController {
    @IBOutlet var bbiCancel: UIBarButtonItem!
    
    @IBOutlet var bbiEdit: UIBarButtonItem!
    @IBOutlet var bbiSave: UIBarButtonItem!
    @IBOutlet fileprivate var txtName: UITextField!
    @IBOutlet fileprivate var txtCode: UITextField!
    @IBOutlet fileprivate var txtPhone: UITextField!
    @IBOutlet fileprivate var tarAddress: UITextView!
    
    var customer = CustomerViewDTO()
    var rowPosition = 0
    var delegate: OnBackButtonClickListener?
    
    fileprivate var isEdited = false
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
        
        print("row postion in summary = \(rowPosition)")
    }
    
    //-> cancelClick
    @IBAction func cancelClick(_ sender: UIBarButtonItem) {
        handCancel()
    }
    
    //-> saveClick
    @IBAction func saveClick(_ sender: UIBarButtonItem) {
        handleSave()
    }
    
    //-> editClick
    @IBAction func editClick(_ sender: UIBarButtonItem) {
        handleEdit()
    }
}

//*** CustomerSummaryTableViewController
extension CustomerSummaryTableViewController {
    
    //-> willDisplayHeaderView
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Arial", size: 16)
        header.textLabel?.text? = header.textLabel?.text?.capitalized ?? ""
    }
}

//*** function  *** /
extension CustomerSummaryTableViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        setupNavBar()
        setupData()
    }
    
    //-> setupNavBar
    fileprivate func setupNavBar() {
        navigationItem.rightBarButtonItems = []
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CustomerSummaryTableViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    //-> back
    @objc func back(sender: UIBarButtonItem) {
        if(isEdited) {
            delegate?.updateTableRow(data: customer, position: rowPosition)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    //-> setupData
    fileprivate func setupData(){
        IndicatorHelper.showIndicator(view: self.view)
        let url = ApiHelper.customerEndPoint + "\(self.customer.id!)"
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.get)
        Alamofire.request(request).responseJSON {
            (response) in
            IndicatorHelper.hideIndicator()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                do {
                    self.navigationItem.rightBarButtonItems = [self.bbiEdit]
                    guard let data = response.data as Data! else { return }
                    let json = try JSONDecoder().decode(CustomerViewDTO.self, from: data)
                    self.customer.name = json.name
                    self.customer.code = json.code
                    self.customer.phone = json.phone
                    self.customer.address = json.address
                    self.displayData()
                }
                catch {
                    self.navigationItem.rightBarButtonItems = []
                    self.navigationController?.view.makeToast(ConstantHelper.errorOccurred)
                }
            }
        }
    }
    
    //-> displayData
    fileprivate func displayData() {
        txtName.text = customer.name
        txtCode.text = customer.code
        txtPhone.text = customer.phone
        tarAddress.text = customer.address
        enableComponents()
    }
    
    //-> enableComponents
    fileprivate func enableComponents(isEnable:Bool = true ) {
        txtName.isUserInteractionEnabled = !isEnable
        txtName.isEnabled = !isEnable
        txtCode.isEnabled = false
        txtPhone.isEnabled = !isEnable
        tarAddress.isEditable = !isEnable
    }
    
    //-> handleEdit
    fileprivate func handleEdit() {
        navigationItem.rightBarButtonItems = []
        navigationItem.rightBarButtonItems = [bbiSave, bbiCancel]
        enableComponents(isEnable: false)
        txtName.becomeFirstResponder()
    }
    
    //-> handleSave
    fileprivate func handleSave() {
        if(isValidated()) {
            do {
                let customer = CustomerEditDTO()
                    customer.id = self.customer.id
                    customer.name = txtName.text!
                    customer.phone = txtPhone.text!
                    customer.address = tarAddress.text!
                let url = ApiHelper.customerEndPoint + "\(self.customer.id!)"
                var request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.put)
                request.httpBody = try JSONEncoder().encode(customer)
                IndicatorHelper.showIndicator(view: self.view)
                Alamofire.request(request).responseJSON {
                    (response) in
                    IndicatorHelper.hideIndicator()
                    if  ApiHelper.isSuccessful(vc: self, response: response){
                        self.isEdited = true
                        self.setupData()
                    }
                }
            }
            catch {
                self.navigationController?.view.makeToast(ConstantHelper.errorOccurred)
            }
        }
    }
    
    //-> handCancel
    fileprivate func handCancel() {
        navigationItem.rightBarButtonItems = []
        navigationItem.rightBarButtonItems = [bbiEdit]
        self.displayData()
    }
    
    //-> validation
    fileprivate func isValidated() -> Bool {
        //--since I could not find the best solution to address this validation issue so that temporary I will this way first
        if(txtName.text == "") {
            self.navigationController?.view.makeToast("Customer Name is required")
            return false
        }
        else if(txtPhone.text == "") {
            self.navigationController?.view.makeToast("Phone number is required")
            return false
        }
        return true
    }
}



