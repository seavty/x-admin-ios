//
//  ReceiveSummaryTableViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/21/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class ReceiveSummaryTableViewController: UITableViewController {
    
    @IBOutlet var bbiSave: UIBarButtonItem!
    
    @IBOutlet var btnItem: UIButton!
    
    @IBOutlet var txtCode: UITextField!
    @IBOutlet var txtQuantity: UITextField!
    @IBOutlet var txtCost: UITextField!
    
    var receiveItem = ReceiveItemNewDTO()
    var receiveItems = [ReceiveItemNewDTO]()
    var rowPosition = -1
    var isIssueController = false
    var updatedListener: OnUpdatedListener?
    var massSavedListener: OnMassSavedListener?
    
    fileprivate var isMassSaved = false
    
    fileprivate struct StoryBoardInfo {
        static let selectItemSegue = "SelectItemSegue"
    }
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }
    
    //-> saveClick
    @IBAction func saveClick(_ sender: UIBarButtonItem) {
        handleSave()
    }
    
    //-> itemClick
    @IBAction func itemClick(_ sender: UIButton) {
        //print("itemClick")
    }
    
    //-> prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case StoryBoardInfo.selectItemSegue?:
            guard let vc = segue.destination as? ItemViewController else {return}
            vc.isFromReceiveSummaryTableViewController = true
            vc.selectTableRowListener = self
        default:
            print("no segue")
        }
    }
}


//*** table view *** //
extension ReceiveSummaryTableViewController {
    
    //-> willDisplayHeaderView
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Arial", size: 16)
        header.textLabel?.text? = header.textLabel?.text?.capitalized ?? ""
        if isIssueController && section == 3 {
            header.textLabel?.text? = "Price (*)"
            header.textLabel?.text = header.textLabel?.text?.capitalized ?? ""
        }
    }
}
//*** end table view ***//

//*** function ***/
extension ReceiveSummaryTableViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        setupNavBar()
        changesForIssueController()
        if(rowPosition > -1) {
            displayData()
        }
    }
    
    //-> setupNavBar
    fileprivate func setupNavBar() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CustomerSummaryTableViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    //-> changesForIssueController
    fileprivate func changesForIssueController() {
        if isIssueController {
            if rowPosition == -1 {
                txtCost.placeholder = "Price"
            }
        }
    }
    
    
    //-> back
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.view.hideAllToasts()
        if isMassSaved {
            massSavedListener?.massSaved(data: receiveItems)
            navigationController?.popViewController(animated: true)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    //-> displayData
    fileprivate func displayData() {
        btnItem.setTitle(receiveItem.name, for: .normal)
        txtCode.text = receiveItem.code
        txtQuantity.text = receiveItem.quantity?.toString
        txtCost.text = receiveItem.cost?.to2Decimal
    }
    
    //-> enableComponents
    fileprivate func enableComponents(isEnable:Bool = true ) {
        btnItem.isEnabled = !isEnable
        txtCode.isEnabled = !isEnable
        txtQuantity.isEnabled = !isEnable
        txtCost.isEnabled = !isEnable
    }
    
    //-> handleSave
    fileprivate func handleSave() {
        self.navigationController?.view.hideAllToasts()
        if(isValidated()) {
            let receiveItem = ReceiveItemNewDTO()
            receiveItem.id = self.receiveItem.id
            receiveItem.name = self.receiveItem.name
            receiveItem.code  = self.receiveItem.code
            receiveItem.quantity = txtQuantity.text?.toInt
            receiveItem.cost = txtCost.text?.toDouble
            self.receiveItems.append(receiveItem)
            
            
            if(rowPosition == -1) {
                self.navigationController?.view.makeToast("Saved successfully", duration: 3.0, position: .center)
                isMassSaved = true
                clearData()
            }
            else {
                updatedListener?.updateTableRow(data: receiveItem, position: rowPosition)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //-> clearData
    fileprivate func clearData() {
        btnItem.setTitle(nil, for: .normal)
        btnItem.titleLabel?.text = nil
        txtCode.text = nil
        txtQuantity.text = nil
        txtCost.text = nil
        txtQuantity.becomeFirstResponder()
        
        if isIssueController {
            txtCost.placeholder = "Price"
        }
    }
    
    //-> handCancel
    fileprivate func handCancel() {
        displayData()
    }
    
    //-> validation
    fileprivate func isValidated() -> Bool {
        //--since I could not find the best solution to address this validation issue so that temporary I will this way first
        if (btnItem.titleLabel?.text == nil) {
            self.navigationController?.view.makeToast("Item is required", duration: 3.0, position: .center)
            return false
        }
        
        else if (txtQuantity.text == "") {
            self.navigationController?.view.makeToast("Quantity is required", duration: 3.0, position: .center)
            return false
        }
            
        if isIssueController {
            if(txtCost.text == "") {
                self.navigationController?.view.makeToast("Price is required", duration: 3.0, position: .center)
                return false
            }
        }
        else {
            if(txtCost.text == "") {
                self.navigationController?.view.makeToast("Cost is required", duration: 3.0, position: .center)
                return false
            }
        }
        
        return true
    }
    
}
//*** end function ***//

//*** handle protocol ***//
extension ReceiveSummaryTableViewController: OnSelectedTableRowListener {
    
    //-> selectTableRow
    func selectTableRow<T>(data: T, position: Int) {
        guard let item = data as? ItemViewDTO else {return}
        btnItem.setTitle(item.name, for: .normal)
        receiveItem.id = item.id
        receiveItem.name = item.name
        receiveItem.code = item.code
        txtCode.text = item.code
    }
}
//*** handle protocol ***//
