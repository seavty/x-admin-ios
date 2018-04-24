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
        setupDataSource()
        setupNavbar()
        isEnableSumbitButton()
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
    
    //-> handleSumbit
    fileprivate func handleSumbit() {
        print("Handle Ok logic here sumbit")
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
                submitIssueItems.warehouseID = ApiHelper.getWarehouseID()
                submitIssueItems.remarks = tvRemarks.text
                submitIssueItems.items = issueItems
                request = ApiHelper.getRequestHeader(url: ApiHelper.issueEndPoint, method: RequestMethodEnum.post)
                request.httpBody = try JSONEncoder().encode(submitIssueItems)
                
            }
            else {
                let submitReceiveItems = SubmitItemDTO<ReceiveItemNewDTO>()
                submitReceiveItems.warehouseID = ApiHelper.getWarehouseID()
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
    
    //->
    fileprivate func clearData() {
        tvRemarks.text = nil
        tableItemDataSource?.receiveItems.removeAll()
        tblItem.reloadData()
        isEnableSumbitButton()
    }
}
//*** end function ***//


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
        let firstSectionHeight:CGFloat = 140
        if indexPath.section == 0 {
            return firstSectionHeight
        }
        return tableView.frame.size.height - firstSectionHeight
    }
}
//*** table view ***/



//*** handle protocol ***//
extension ReceiveTableViewController: OnMassSavedListener, OnUpdatedListener {
    
    //-> updateTableRow
    func updateTableRow<T>(data: T, position: Int) {
        guard let receiveItem = data as? ReceiveItemNewDTO else {return}
        tableItemDataSource?.receiveItems[position] = receiveItem
        tblItem.reloadData()
    }
    
    //-> massSaved
    func massSaved<T>(data: [T]) {
       guard let receiveItems = data as? [ReceiveItemNewDTO] else {return}
        tableItemDataSource?.receiveItems.append(contentsOf: receiveItems)
        tblItem.reloadData()
        isEnableSumbitButton()
    }
}


