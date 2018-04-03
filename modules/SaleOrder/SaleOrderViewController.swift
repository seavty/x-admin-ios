//
//  SaleOrderViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/3/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit

class SaleOrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tblSaleOrder: UITableView!
    
    var saleOrders = [SaleOrderViewDTO]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /*
        var s1 = SaleOrderViewModel()
        s1.id = "1"
        s1.saleOrderNo = "no1"
        saleOrders.append(s1)
        
        var s2 = SaleOrderViewModel()
        s2.id = "2"
        s2.saleOrderNo = "no2"
        saleOrders.append(s2)
        */
        
        initializeComponents()
    }
    
    func initializeComponents() {
        tblSaleOrder.dataSource = self
        tblSaleOrder.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saleOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SaleOrderTableViewCell
        //cell.lblSaleOrderNo.text = saleOrders[indexPath.row].id
        //cell.lblCustomerName.text = saleOrders[indexPath.row].saleOrderNo
        return cell
    }

    
}
