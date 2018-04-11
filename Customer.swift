//
//  Customer.swift
//  X-Admin
//
//  Created by SeavTy on 11/27/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Customer: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //var baseURL = Server().apiURL + "customers/"
    var baseURL = CustomeHelper().apiURL() + "customers/"
    
    @IBOutlet var tblCustomer: UITableView!
    
    var customerModels = [CustomerModel]()
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
        tblCustomer.dataSource = self;
        tblCustomer.delegate = self;
        createSearchBar()
        createRefreshControl()
        resetData()
    }
    
    fileprivate func createRefreshControl() {
        refreshControll.attributedTitle = NSAttributedString(string: "Pull to Refresh !");
        refreshControll.addTarget(self, action: #selector(Customer.refreshControlFunc(refreshControl:)), for: UIControlEvents.valueChanged)
        self.tblCustomer.addSubview(refreshControll);
    }
    
    @objc func refreshControlFunc( refreshControl: UIRefreshControl) {
        searchBar.text = nil
        resetData()
        refreshControll.endRefreshing()
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customerModels.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomerCell
        
        if(customerModels.count > 0) {
            cell.setCustomer(model: customerModels[indexPath.row])
        }
        else {
            self.tblCustomer.reloadData()
        }
        
        //This creates the shadows and modifies the cards a little bit
        /*
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        */
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == customerModels.count - 1 && !isEof {
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
        self.performSegue(withIdentifier: "CustomerSummary", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CustomerSummary"){
            let vc = segue.destination as! CustomerSummary
            vc.customerModel = self.customerModels[selectIndexPath!.row]
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
                self.loadDataToTable(value: response.result.value!)
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
    
    //-- Delete --//
    fileprivate func deleteRecord(indexPath: IndexPath) {
        let model = self.customerModels[indexPath.row]
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
                self.customerModels.remove(at: indexPath.row)
                self.tblCustomer.reloadData()
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
            let model = CustomerModel()
            model.id = resultsJson[i]["id"].stringValue
            model.name = resultsJson[i]["name"].stringValue
            model.code = resultsJson[i]["code"].stringValue
            model.phone = resultsJson[i]["phone"].stringValue
            model.address = resultsJson[i]["address"].stringValue
                
            self.customerModels.append(model)
        }
         self.tblCustomer.reloadData()
    }
    
    //-- Searchbar ---//
    fileprivate func createSearchBar(){
        searchBar.placeholder = "Customer Name"
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
        self.customerModels.removeAll()
        isEof = false
        curentPagePosition = 1
        getList()
    }
    
    
}
