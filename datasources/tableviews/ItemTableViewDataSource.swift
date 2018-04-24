//
//  ItemTableViewDataSource.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/21/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import UIKit

class ItemTableViewDataSource: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var receiveItems = [ReceiveItemNewDTO]()
    var isIssueModule = false
    var selectedTableRowListner: OnSelectedTableRowListener?
    var vc : UIViewController?
    
    fileprivate struct StoryBoardInfo {
        static let tableItemCellIdentifier = "cell"
        static let receiveItemSummarySegue = "ReceiveItemSummarySegue"
    }
    
    //-> numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receiveItems.count
    }
    
    //-> cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoardInfo.tableItemCellIdentifier, for: indexPath) as! ItemTableViewCellForDataSource
        cell.setReceiveItem(receiveItem: receiveItems[indexPath.row], isIssueModule: isIssueModule)
        return cell
    }
    
    //-> commit editingStyle
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.receiveItems.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
            
            guard let myVC = vc as? ReceiveTableViewController else {return}
            myVC.isEnableSumbitButton()
            
        }
    }
    
    //-> didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vc?.performSegue(withIdentifier:StoryBoardInfo.receiveItemSummarySegue , sender: indexPath.row)
    }
}

