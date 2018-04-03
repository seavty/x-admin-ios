//
//  ItemGroup.swift
//  X-Admin
//
//  Created by SeavTy on 12/15/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ItemGroup: UITableViewController, UISearchBarDelegate {

    //var baseURL = Server().apiURL + "itemgroups/"
    var baseURL = CustomeHelper().apiURL() + "itemgroups/"
    
    @IBOutlet var tblItemGroup: UITableView!
    
    //var itemGroupModels = [ItemGroupModel]()
    var itemGroupWithDocument = [ItemGroupWithDocumentModel]()
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
        tblItemGroup.dataSource = self;
        tblItemGroup.delegate = self;
        createSearchBar()
        createRefreshControl()
        resetData()
    }
    
   fileprivate func createRefreshControl() {
        refreshControll.attributedTitle = NSAttributedString(string: "Pull to Refresh !");
        refreshControll.addTarget(self, action: #selector(ItemGroup.refreshControlFunc(refreshControl:)), for: UIControlEvents.valueChanged)
        self.tblItemGroup.addSubview(refreshControll);
    }
    
    
    @objc func refreshControlFunc( refreshControl: UIRefreshControl) {
        searchBar.text = nil
        resetData()
        refreshControll.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    //-- *** table view controller function *** --//
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemGroupWithDocument.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemGroupCell
        
        if(itemGroupWithDocument.count > 0) {
            cell.setItemGroup(model: itemGroupWithDocument[indexPath.row])
        }
        else {
            self.tblItemGroup.reloadData()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == itemGroupWithDocument.count - 1 && !isEof {
             getList()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            deleteRecord(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndexPath = indexPath
        self.performSegue(withIdentifier: "ItemGroupSummary", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ItemGroupSummary"){
            let vc = segue.destination as! ItemGroupSummary
            vc.itemGroupWithDocument = self.itemGroupWithDocument[selectIndexPath!.row]
            //vc.itemGroup = self.itemGroupModels[selectIndexPath!.row]
        }
    }
    
    //-- end table function  --//
    
    
    
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
    
    //-- Delete --//
    fileprivate func deleteRecord(indexPath: IndexPath) {
        let model = self.itemGroupWithDocument[indexPath.row]
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
                self.itemGroupWithDocument.remove(at: indexPath.row)
                self.tblItemGroup.reloadData()
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
        }
        else {
            isEof = true
        }
        
        let resultsJson = json["results"]
        for i in 0 ..< resultsJson.count {
            let itemGroupWithDocument = ItemGroupWithDocumentModel()
            itemGroupWithDocument.id = resultsJson[i]["id"].stringValue
            itemGroupWithDocument.name = resultsJson[i]["name"].stringValue
            
            let documentJson = resultsJson[i]["documents"]
            var documents = [DocumentModel]()
            for j in 0 ..< documentJson.count {
                let document = DocumentModel()
                document.id = documentJson[j]["id"].intValue
                document.name = documentJson[j]["name"].stringValue
                document.path = documentJson[j]["path"].stringValue
                documents.append(document)
            }
            itemGroupWithDocument.documents = documents
            self.itemGroupWithDocument.append(itemGroupWithDocument)
        }
        self.tblItemGroup.reloadData()
    }
    
    //-- *** end  CRUD Operation *** -- //
    
    
    //-- Searchbar ---//
    fileprivate func createSearchBar(){
        searchBar.placeholder = "Item Group Name"
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
        self.itemGroupWithDocument.removeAll()
        isEof = false
        curentPagePosition = 1
        getList()
    }

}
