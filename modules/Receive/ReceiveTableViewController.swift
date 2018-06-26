//
//  ReceiveTableViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/21/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class ReceiveTableViewController: UITableViewController {

    @IBOutlet var bbiSubmit: UIBarButtonItem!
    @IBOutlet var tblItem: UITableView!
    
    @IBOutlet var tvRemarks: UITextView!
    
    var tableItemDataSource: ItemTableViewDataSource?
    
    var isIssueModule = false
    
    @IBOutlet var txtWarehouse: UITextField!
    
    fileprivate var warehouses: [(Int, String)] = []
    fileprivate var selectedPickerRow: Int?
    
    let warehousePicker = UIPickerView()
    
    struct StoryBoardInfo {
        static let createReceiveItemSegue = "CreateReceiveItemSegue"
        static let receiveItemSummarySegue = "ReceiveItemSummarySegue"
    }
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }
    
    //-> prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        dimissKeyboard()
        switch segue.identifier {
        case StoryBoardInfo.createReceiveItemSegue?:
            guard let vc = segue.destination as? ReceiveSummaryTableViewController else {return}
            vc.massSavedListener = self
            vc.isIssueController = isIssueModule
        case StoryBoardInfo.receiveItemSummarySegue?:
            guard let vc = segue.destination as? ReceiveSummaryTableViewController else {return}
            guard let position = sender as? Int else {return}
            let receiveItem = tableItemDataSource?.receiveItems[position]
            vc.receiveItem = receiveItem!
            vc.rowPosition = position
            vc.updatedListener = self
            
        default:
            print("no segue")
        }
    }
 
    //-> submitClick
    @IBAction func submitClick(_ sender: UIBarButtonItem) {
        if (tableItemDataSource?.receiveItems.count == 0) {
            self.navigationController?.view.makeToast("Cannot submit your request without item(s)!", duration: 3.0, position: .center)
        }
        else {
            let alert = UIAlertController(title: "Sumbit", message: "Do you want to sumbit data to server?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                self.handleSumbit()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//*** function ***//
extension ReceiveTableViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        self.txtWarehouse.delegate = self
        setupDataSource()
        setupNavbar()
        isEnableSumbitButton()
        setupWarehousePicker()
        
        self.getWarehouses()
    }
    
    //-> file setupDatasouce
    fileprivate func setupDataSource() {
        tableItemDataSource = ItemTableViewDataSource()
        tableItemDataSource?.vc = self
        tableItemDataSource?.isIssueModule = isIssueModule
        tblItem.dataSource = tableItemDataSource
        tblItem.delegate = tableItemDataSource
    }
    
    //-> setupNavbar
    fileprivate func setupNavbar(){
        if isIssueModule {
            navigationItem.title = "Issue"
        }
        isEnableSumbitButton()
    }
    
    //-> isEnableSumbitButton
    func isEnableSumbitButton() {
        let countItems = tableItemDataSource?.receiveItems.count ?? 0
        if countItems > 0 {
            bbiSubmit.isEnabled = true
        }
        else {
            bbiSubmit.isEnabled = false
        }
    }
    
    //-> setup warehouse picker
    func setupWarehousePicker() {
        warehousePicker.delegate = self
        txtWarehouse.inputView = warehousePicker
        setupToolBarForWarehousePicker()
    }
    
    //-> setupToolBarForWarehousePicker
    func setupToolBarForWarehousePicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ReceiveTableViewController.dimissKeyboard))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtWarehouse.inputAccessoryView = toolBar
    }
    
    //-> dimissKeyboard
    @objc func dimissKeyboard() {
        view.endEditing(true)
    }
    
    //-> handleSumbit
    fileprivate func handleSumbit() {
        do {
            var request = ApiHelper.getRequestHeader(url: ApiHelper.receiveEndPoint, method: RequestMethodEnum.post)
            
            /*
            let submitItem = SubmitItemDTO<ReceiveItemNewDTO>()
                submitItem.warehouseID = ApiHelper.getWarehouseID()
                submitItem.remarks = tvRemarks.text
                submitItem.items = tableItemDataSource?.receiveItems
            */
            if isIssueModule {
                var issueItems = [IssueItemNewDTO]()
                let myItems = tableItemDataSource?.receiveItems
                for receive in myItems! {
                    let issue = IssueItemNewDTO()
                    issue.id = receive.id
                    issue.name = receive.name
                    issue.code = receive.code
                    issue.quantity = receive.quantity
                    issue.price = receive.cost
                    issueItems.append(issue)
                }
                let submitIssueItems = SubmitItemDTO<IssueItemNewDTO>()
                //submitIssueItems.warehouseID = ApiHelper.getWarehouseID()
                submitIssueItems.warehouseID = self.warehouses[selectedPickerRow!].0
                submitIssueItems.remarks = tvRemarks.text
                submitIssueItems.items = issueItems
                request = ApiHelper.getRequestHeader(url: ApiHelper.issueEndPoint, method: RequestMethodEnum.post)
                request.httpBody = try JSONEncoder().encode(submitIssueItems)
                
            }
            else {
                let submitReceiveItems = SubmitItemDTO<ReceiveItemNewDTO>()
                //submitReceiveItems.warehouseID = ApiHelper.getWarehouseID()
                submitReceiveItems.warehouseID = self.warehouses[selectedPickerRow!].0
                submitReceiveItems.remarks = tvRemarks.text
                submitReceiveItems.items = tableItemDataSource?.receiveItems
                request = ApiHelper.getRequestHeader(url: ApiHelper.receiveEndPoint, method: RequestMethodEnum.post)
                request.httpBody = try JSONEncoder().encode(submitReceiveItems)
            }
            
            
            
            //request.httpBody = try JSONEncoder().encode(submitItem)
            IndicatorHelper.showIndicator(view: self.view)
            Alamofire.request(request).responseJSON {
                (response) in
                IndicatorHelper.hideIndicator()
                if  ApiHelper.isSuccessful(vc: self, response: response){
                    self.navigationController?.view.makeToast("Your data has been successfully submitted to server", duration: 3.0, position: .center)
                    self.clearData()
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    //-> clearData
    fileprivate func clearData() {
        tvRemarks.text = nil
        tableItemDataSource?.receiveItems.removeAll()
        tblItem.reloadData()
        isEnableSumbitButton()
    }
    
    //-> getWarehouses
    fileprivate func getWarehouses() {
        let url = ApiHelper.warehouseEndPoint + "?currentPage=\(1)"
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.get)
        IndicatorHelper.showIndicator(view: self.view)
        Alamofire.request(request).responseJSON {
            response in
            IndicatorHelper.hideIndicator()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                do {
                    guard let data = response.data as Data! else { return }
                    let json = try JSONDecoder().decode(GetListDTO<WarehouseViewDTO>.self, from: data)
                    guard let warehouses = json.results else {return}
                    if warehouses.count > 0 {
                        for warehouse in warehouses {
                            self.warehouses.append((warehouse.id!, warehouse.name!))
                        }
                        guard let index = self.warehouses.index(where: { $0.0 == ApiHelper.getWarehouseID() }) else { return }
                        self.warehousePicker.selectRow(index, inComponent:0, animated:true)
                        self.txtWarehouse.text = self.warehouses[index].1
                        self.selectedPickerRow = index
                    }
                }
                catch {
                    self.view.makeToast(ConstantHelper.errorOccurred)
                }
            }
        }
    }
}
//*** end function ***//

//** UITextFieldDelegate **//
extension ReceiveTableViewController: UITextFieldDelegate {
    
    //-> shouldChangeCharactersIn
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
//** end UITextFieldDelegate **//




//*** table view *** //
extension ReceiveTableViewController {
   
    //-> willDisplayHeaderView
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Arial", size: 16)
        header.textLabel?.text? = header.textLabel?.text?.capitalized ?? ""
    }
    
    //-> heightForRowAt
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let firstSectionHeight:CGFloat = 50
        let secondSectionHeight:CGFloat = 140
        if indexPath.section == 0 {
            return firstSectionHeight
        }
        if indexPath.section == 1  {
            return secondSectionHeight
        }
        return tableView.frame.size.height - firstSectionHeight - secondSectionHeight
    }
}
//*** end table view ***//



//*** handle protocol ***//
extension ReceiveTableViewController: OnMassSavedListener, OnUpdatedListener {
    
    //-> updateTableRow
    func updateTableRow<T>(data: T, position: Int) {
        guard let receiveItem = data as? ReceiveItemNewDTO else {return}
        tableItemDataSource?.receiveItems[position] = receiveItem
        let indexPath = IndexPath(row: position, section: 0)
        tblItem.reloadRows(at: [indexPath], with: .middle)
        tblItem.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    //-> massSaved
    func massSaved<T>(data: [T]) {
        guard let receiveItems = data as? [ReceiveItemNewDTO] else {return}
        if receiveItems.count > 0 {
            tblItem.beginUpdates()
            for item in receiveItems {
                tableItemDataSource?.receiveItems.append(item)
                let indexPath:IndexPath = IndexPath(row:((tableItemDataSource?.receiveItems.count)! - 1), section:0)
                tblItem.insertRows(at: [indexPath], with: .automatic)
            }
            tblItem.endUpdates()
        }
        isEnableSumbitButton()
    }
}
//*** end protocol ***//

//*** pickerviewr ***//
extension ReceiveTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    //-> numberOfComponents
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //-> numberOfRowsInComponent
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return warehouses.count
    }
    
    //-> titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return warehouses[row].1
    }
    
    //-> didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerRow = row
        txtWarehouse.text = warehouses[row].1
    }
}
//*** end pickerviewr ***//


