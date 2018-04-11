//
//  SaleOrderViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/3/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class SaleOrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let apiURL = ApiHelper().apiURL() + "saleorders/"
    
    @IBOutlet var tblSaleOrder: UITableView!
    
    var saleOrders = [SaleOrderViewDTO]()
    var currentPage:Int = 1
    var isEOF = false
    
    var refreshControll = UIRefreshControl()
    
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
        refreshControll.attributedTitle = NSAttributedString(string: "");
        refreshControll.addTarget(self, action: #selector(SaleOrderViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.tblSaleOrder.addSubview(refreshControll)
    }
    
    //-> handleRefresh
    @objc func handleRefresh( refreshControl: UIRefreshControl) {
        //searchBar.text = nil
        resetData()
        refreshControll.endRefreshing()
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
        return 60
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
            //deleteRecord(indexPath: indexPath)
        }
    }
    
    //-> getSaleOrders
    fileprivate func getSaleOrders() {
        let url = apiURL + "?currentPage=\(currentPage)"
        let request = ApiHelper().getRequestHeader(url: url, method: RequestMethod.get)
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            response in
            LoadingOverlay.shared.hideOverlayView()
            let statusCode = response.response?.statusCode ?? 0
            print(statusCode)
            
            
            if  ApiHelper().isSuccessful(vc: self, statusCode: statusCode) {
                do {
                    guard let data = response.data as Data! else {return}
                    let results = try JSONDecoder().decode(SaleOrderListDTO.self, from:data)
                    let totalPage = results.metaData?.totalPage ?? 0
                    if(self.currentPage <= totalPage) {
                        self.currentPage = self.currentPage + 1
                        self.saleOrders.append(contentsOf: results.results!)
                        self.tblSaleOrder.reloadData()
                    }
                    else {
                        self.isEOF = true
                    }
                    
                }
                catch {
                    print("caught: \(error)")
                }
            }
            
        }
    }
    
    
}
