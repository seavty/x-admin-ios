//
//  SearchItem.swift
//  X-Admin
//
//  Created by SeavTy on 1/11/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchItem: UITableViewController, UISearchBarDelegate {

    var baseURL = Server().apiURL + "items/"
    
    @IBOutlet var tblSearchItem: UITableView!
    
    var itemModels = [ItemModel]()
    var selectIndexPath:IndexPath?
    
    var isEof:Bool = false
    
    var refreshControll = UIRefreshControl();
    var searchBar = UISearchBar()
    
    var curentPagePosition:Int = 0
    
    //----------- *** ------------//
    override func viewDidLoad() {
        super.viewDidLoad()
        initComp()
    }
    
    fileprivate func initComp() {
        tblSearchItem.dataSource = self;
        tblSearchItem.delegate = self;
        createSearchBar()
        createRefreshControl()
        resetData()
    }
    
    fileprivate func createRefreshControl() {
        refreshControll.attributedTitle = NSAttributedString(string: "Pull to Refresh !");
        refreshControll.addTarget(self, action: #selector(Item.refreshControlFunc(refreshControl:)), for: UIControlEvents.valueChanged)
        self.tblSearchItem.addSubview(refreshControll);
    }
    
    func refreshControlFunc( refreshControl: UIRefreshControl) {
        searchBar.text = nil
        resetData()
        refreshControll.endRefreshing()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemModels.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchItemCell
        
        if(itemModels.count > 0) {
            cell.setItem(model: itemModels[indexPath.row])
        }
        else {
            self.tblSearchItem.reloadData()
        }
        
        return cell
    }
    
   override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == itemModels.count - 1 && !isEof {
            getList()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndexPath = indexPath
        // here need to change
        //self.performSegue(withIdentifier: "ReceiveSummary", sender: self)
        
        if let vc = self.navigationController!.viewControllers[1] as? ReceiveSummary {
            vc.isRefresh = true
            vc.itemModel = itemModels[selectIndexPath!.row]
            self.navigationController?.popToViewController(vc, animated: true)
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
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            response in
            LoadingOverlay.shared.hideOverlayView();
            
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                self.self.loadDataToTable(value: response.result.value!)
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
            let model = ItemModel()
            model.id = resultsJson[i]["id"].stringValue
            model.code = resultsJson[i]["code"].stringValue
            model.name = resultsJson[i]["name"].stringValue
            model.description = resultsJson[i]["description"].stringValue
            
            let itemgroupModel = ItemGroupModel()
            let itemGroup = resultsJson[i]["itemGroup"]
            itemgroupModel.id = itemGroup["id"].stringValue
            itemgroupModel.name = itemGroup["name"].stringValue
            
            model.itemGroup = itemgroupModel
            self.itemModels.append(model)
        }
        self.tblSearchItem.reloadData()
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
