//
//  ItemGroupCheckbox.swift
//  X-Admin
//
//  Created by SeavTy on 1/2/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ItemGroupCheckbox: UITableViewController {
    
    //var baseURL = Server().apiURL + "itemgroups/"
    var baseURL = CustomeHelper().apiURL() + "itemgroups/"
    
    var itemGroupModels = [ItemGroupModel]()
    
    var itemModel = ItemModel()
    var selectIndexPath:IndexPath?
    
    @IBOutlet var tbl: UITableView!
    
    //----------- *** ------------//
    override func viewDidLoad() {
        super.viewDidLoad()
        initComp()
    }
    
    func initComp() {
        tbl.dataSource = self;
        tbl.delegate = self;
        getList(currentPage: "1");
    }
    // MARK: - Table view data source
    
    //-- *** table view controller function *** --//
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemGroupModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemGroupCheckboxCell
        
        cell.setItemGroup(model: itemGroupModels[indexPath.row])
        if(itemGroupModels[indexPath.row].id == itemModel.itemGroup.id) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            selectIndexPath = indexPath
        }
        else {
           cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let myIndexPath = selectIndexPath {
            tbl.cellForRow(at: myIndexPath)?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        
        //tbl.cellForRow(at: selectIndexPath!)?.accessoryType = UITableViewCellAccessoryType.none
        tbl.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        selectIndexPath = indexPath
        
        itemModel.itemGroup.id = itemGroupModels[indexPath.row].id
        itemModel.itemGroup.name = itemGroupModels[indexPath.row].name
        
        if let vc = self.navigationController!.viewControllers[1] as? ItemSummary {
            vc.isReload = true
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tbl.cellForRow(at: selectIndexPath!)?.accessoryType = UITableViewCellAccessoryType.none
        tbl.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
    }
    
    
    func getList(currentPage: String){
        let url = baseURL + "?currentPage=" + currentPage
        
        let request = CustomeHelper().getRequestHeader(url: url, method: RequestMethod.get)
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            response in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                self.self.loadData(value: response.result.value!)
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
    
    //-- read --> get list
    func loadData(value : Any) {
        var json = JSON(value)
        
        if json["metaData"].exists() {
            json = json["results"]
        }
        
        if(json.count > 0) {
            for i in 0 ..< json.count {
                let model = ItemGroupModel()
                model.id = json[i]["id"].stringValue
                model.name = json[i]["name"].stringValue
                
                self.itemGroupModels.append(model)
            }
            //isEof = false
            self.tbl.reloadData()
        }
        else {
            //isEof = true
        }
        
        
    }

}
