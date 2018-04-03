//
//  Item.swift
//  X-Admin
//
//  Created by SeavTy on 12/14/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Item: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //var baseURL = Server().apiURL + "items/"
    var baseURL = CustomeHelper().apiURL() + "items/"
    
    @IBOutlet var tblItem: UITableView!
    
    var itemModels = [ItemModel]()
    var selectIndexPath:IndexPath?
    
    var isEof:Bool = false
    var isRefresh:Bool = false
    
    var refreshControll = UIRefreshControl();
    var searchBar = UISearchBar()
    
    var curentPagePosition:Int = 0
    
    //----------- *** ------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(isRefresh){
            isRefresh = false
            resetData()
        }
    }
    
    fileprivate func initComp() {
        tblItem.dataSource = self;
        tblItem.delegate = self;
        createSearchBar()
        createRefreshControl()
        resetData()
    }
    
    fileprivate func createRefreshControl() {
        refreshControll.attributedTitle = NSAttributedString(string: "Pull to Refresh !");
        refreshControll.addTarget(self, action: #selector(Item.refreshControlFunc(refreshControl:)), for: UIControlEvents.valueChanged)
        self.tblItem.addSubview(refreshControll);
    }
    
    @objc func refreshControlFunc( refreshControl: UIRefreshControl) {
        searchBar.text = nil
        resetData()
        refreshControll.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    //-- *** table view controller function *** --//
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemModels.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemCell
        
        if(itemModels.count > 0) {
            cell.setItem(model: itemModels[indexPath.row])
        }
        else {
            self.tblItem.reloadData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == itemModels.count - 1 && !isEof {
            getList()
        }
    }
        
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            deleteRecord(indexPath: indexPath)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndexPath = indexPath
        self.performSegue(withIdentifier: "ItemSummary", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ItemSummary"){
            let vc = segue.destination as! ItemSummary
            vc.itemModel = self.itemModels[selectIndexPath!.row]
        }
    }
    
    //-- *** end table view controller function *** --//
    
    
    //-- *** CRUD Operation *** -- //
    //-- Read --//
    fileprivate func getList(){
        var url = ""
        if(searchBar.text! == "") {
           url = baseURL + "?currentPage=" + String(curentPagePosition)
        }
        else {
            let searchString = searchBar.text!
            let escapedString = searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            url = baseURL + "?currentPage=" + String(curentPagePosition) +  "&search=" +  escapedString!
        }
        let request = CustomeHelper().getRequestHeader(url: url, method: RequestMethod.get)
        LoadingOverlay.shared.showOverlay(view: self.view)
        Alamofire.request(request).responseJSON {
            response in
            LoadingOverlay.shared.hideOverlayView()
            
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                self.self.loadDataToTable(value: response.result.value!)
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }

    //-- Delete --//
    fileprivate func deleteRecord(indexPath: IndexPath) {
        let model = self.itemModels[indexPath.row]
        let url = baseURL + model.id
        
        var request = CustomeHelper().getRequestHeader(url: url, method: RequestMethod.delete)
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
                self.itemModels.remove(at: indexPath.row)
                self.tblItem.reloadData()
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
        
    }
    
    //-- read --> get list
    fileprivate func loadDataToTable(value : Any) {
        var json = JSON(value)
        
        let metaDataJson = json["metaData"]
        let metaDataModel = MetaDataModel()
            metaDataModel.totalPage = metaDataJson["totalPage"].intValue
            
        if(curentPagePosition < metaDataModel.totalPage) {
            curentPagePosition = curentPagePosition + 1
            isEof = false
        }
        else {
            isEof = true
        }
        
        let resultsJson = json["results"]
        for i in 0 ..< resultsJson.count {
            // should creat function that decode jason
            // dont decode like this , bad practice 
            let model = ItemModel()
            model.id = resultsJson[i]["id"].stringValue
            model.code = resultsJson[i]["code"].stringValue
            model.name = resultsJson[i]["name"].stringValue
            model.description = resultsJson[i]["description"].stringValue
            model.price = resultsJson[i]["price"].doubleValue
            
            let itemgroupModel = ItemGroupModel()
            let itemGroup = resultsJson[i]["itemGroup"]
            itemgroupModel.id = itemGroup["id"].stringValue
            itemgroupModel.name = itemGroup["name"].stringValue
                
            model.itemGroup = itemgroupModel
            self.itemModels.append(model)
        }
        self.tblItem.reloadData()
    }
    
    //-- *** end  CRUD Operation *** -- //
    
    
    //-- Searchbar ---//
    fileprivate func createSearchBar(){
        searchBar.placeholder = "Item Name"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        resetData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        resetData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    //-- end  Searchbar ---//
    
    fileprivate func resetData() {
        self.itemModels.removeAll()
        isEof = false
        curentPagePosition = 1
        getList()
    }

}
