//
//  SaleOrderViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/3/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift

class SaleOrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //let apiURL = ApiHelper().apiURL() + "saleorders/"
    let apiURL = ApiHelper.apiURL() + "saleorders/"
    
    @IBOutlet var tblSaleOrder: UITableView!
    
    fileprivate var saleOrders = [SaleOrderViewDTO]()
    fileprivate var currentPage:Int = 1
    fileprivate var isEOF = false
    
    fileprivate var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        tblSaleOrder.dataSource = self
        tblSaleOrder.delegate = self
        
        setupRefreshControl()
        self.getSaleOrders()
    }
    
    //-> setupRefreshControl
    fileprivate func setupRefreshControl() {
        //refreshControll.tintColor = UIColor.red
        refreshControl.attributedTitle = NSAttributedString(string: "");
        refreshControl.addTarget(self, action: #selector(SaleOrderViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.tblSaleOrder.addSubview(refreshControl)
    }
    
    //-> handleRefresh
    @objc func handleRefresh( refreshControl: UIRefreshControl) {
        //searchBar.text = nil
        resetData()
        refreshControl.endRefreshing()
    }
    
    //-> resetData
    fileprivate func resetData() {
        self.saleOrders.removeAll()
        isEOF = false
        currentPage = 1
        getSaleOrders()
    }
    
    //-> heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //-> numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saleOrders.count
    }
    
    //-> cellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SaleOrderTableViewCell
        if(saleOrders.count > 0) {
            cell.setSaleOrder(saleOrder: saleOrders[indexPath.row])
        }
        else {
            self.tblSaleOrder.reloadData()
        }
        return cell
    }
    
    //-> willDisplay
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == saleOrders.count - 1 && !isEOF {
            getSaleOrders()
        }
    }
    
    //-> commit editingStyle
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            deleteSaleOrder(indexPath: indexPath)
        }
    }
    
    //-> deleteSaleOrder
    fileprivate func deleteSaleOrder(indexPath: IndexPath) {
        let saleOrder = self.saleOrders[indexPath.row]
        let url = apiURL + "\(saleOrder.id!)"
        var request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.delete)
        do {
            let json = try JSONEncoder().encode(saleOrder)
            request.httpBody = json
            LoadingOverlay.shared.showOverlay(view: self.view)
            
            //print("request body: \(request.httpBody)")
            print(String(data: request.httpBody!, encoding: .utf8)!)
            
            Alamofire.request(request).responseJSON {
                (response) in
                LoadingOverlay.shared.hideOverlayView()
                if  ApiHelper.isSuccessful(vc: self, response: response){
                    
                }
            }
        }
        catch {
            self.view.makeToast(ConstantHelper.errorOccurred)
        }
    }
    
    //-> getSaleOrders
    fileprivate func getSaleOrders() {
        let url = apiURL + "?currentPage=\(currentPage)"
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.get)
        LoadingOverlay.shared.showOverlay(view: self.view)
        Alamofire.request(request).responseJSON {
            response in
            LoadingOverlay.shared.hideOverlayView()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                do {
                    guard let data = response.data as Data! else { return }
                    let json = try JSONDecoder().decode(GetListDTO<SaleOrderViewDTO>.self, from: data)
                    guard let totalPage = json.metaData?.totalPage as Int! else { return }
                    if(self.currentPage <= totalPage) {
                        self.saleOrders.append(contentsOf: json.results!)
                        self.tblSaleOrder.reloadData()
                        self.currentPage = self.currentPage + 1
                    }
                    else {
                        self.isEOF = true
                    }
                }
                catch {
                    self.view.makeToast(ConstantHelper.errorOccurred)
                }
            }
        }
    }
}
