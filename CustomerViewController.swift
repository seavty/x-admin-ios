//
//  CustomerViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/15/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class CustomerViewController : UIViewController {
    
    @IBOutlet fileprivate var tblCustomer: UITableView!
    @IBOutlet fileprivate var bbiAdd: UIBarButtonItem!
    
    fileprivate var customers = [CustomerViewDTO]()
    fileprivate var currentPage = 1
    fileprivate var isEOF = false
    
    fileprivate var refreshControl = UIRefreshControl()
    fileprivate var searchBar = UISearchBar()
    
    fileprivate struct StoryBoardInfo {
        static let tableCustomerCellIndentifier = "cell"
        static let customerSummarySegue = "CustomerSummarySegue"
        static let createCustomerSegue = "CreateCustomerSegue"
    }
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }
    
    //-> addClick
    @IBAction func addClick(_ sender: UIBarButtonItem) {
        handleAdd()
    }
    
    //-> prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case StoryBoardInfo.createCustomerSegue? :
            guard let vc = segue.destination as? CustomerSummaryTableViewController else {return}
            vc.createdListener = self
        case StoryBoardInfo.customerSummarySegue?:
            guard let vc = segue.destination as? CustomerSummaryTableViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            vc.customer = customers[indexPath.row]
            vc.rowPosition = indexPath.row
            vc.backClickListener = self
        default:
            self.view.makeToast(ConstantHelper.wrongSegueName)
        }
    }
}

//*** function *** //
extension CustomerViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        setupTableView()
        setupSearchBar()
        setupRefreshControl()
        self.getCustomers()
    }
    
    //-> setupTableView
    fileprivate func setupTableView() {
        tblCustomer.dataSource = self
        tblCustomer.delegate = self
    }
    
    //-> setupSearchBar ---//
    fileprivate func setupSearchBar(){
        searchBar.placeholder = "Customer Name / Code"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    //-> setupRefreshControl
    fileprivate func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "");
        refreshControl.addTarget(self, action: #selector(CustomerViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.tblCustomer.addSubview(refreshControl)
    }
    
    //-> resetData
    fileprivate func resetData() {
        self.customers.removeAll()
        isEOF = false
        currentPage = 1
        getCustomers()
    }
    
    //-> handleRefresh
    @objc func handleRefresh( refreshControl: UIRefreshControl) {
        resetData()
        refreshControl.endRefreshing()
    }
    //-> handleAdd
    fileprivate func handleAdd() {
        performSegue(withIdentifier: StoryBoardInfo.createCustomerSegue, sender: self)
    }
    
    //-> deleteCustomer
    fileprivate func deleteCustomer(indexPath: IndexPath) {
        let customer = self.customers[indexPath.row]
        let url = ApiHelper.customerEndPoint + "\(customer.id!)"
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.delete)
        IndicatorHelper.showIndicator(view: self.view)
        Alamofire.request(request).responseJSON {
            (response) in
            IndicatorHelper.hideIndicator()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                self.customers.remove(at: indexPath.row)
                self.tblCustomer.reloadData()
            }
        }
    }
    
    //-> getCustomers
    fileprivate func getCustomers() {
        var url = ApiHelper.customerEndPoint + "?currentPage=\(currentPage)"
        if(searchBar.text != ""){
            let searchText = searchBar.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            url += "&search=\(searchText!)"
        }
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.get)
        IndicatorHelper.showIndicator(view: self.view)
        Alamofire.request(request).responseJSON {
            response in
            IndicatorHelper.hideIndicator()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                do {
                    guard let data = response.data as Data! else { return }
                    let json = try JSONDecoder().decode(GetListDTO<CustomerViewDTO>.self, from: data)
                    guard let totalPage = json.metaData?.totalPage as Int! else { return }
                    if(self.currentPage <= totalPage) {
                        self.customers.append(contentsOf: json.results!)
                        self.tblCustomer.reloadData()
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
//*** end function *** //


//*** TableView *** //
extension CustomerViewController: UITableViewDataSource, UITableViewDelegate {
    //-> heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //-> numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers.count
    }
    
    //-> cellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoardInfo.tableCustomerCellIndentifier, for: indexPath) as! CustomerTableViewCell
        if(customers.count > 0) {
            cell.setCustomer(customer: customers[indexPath.row])
        }
        else {
            self.tblCustomer.reloadData()
        }
        return cell
    }
    
    //-> willDisplay
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == customers.count - 1 && !isEOF {
            getCustomers()
        }
    }
    
    //-> commit editingStyle
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            deleteCustomer(indexPath: indexPath)
        }
    }
    
    //-> didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: StoryBoardInfo.customerSummarySegue, sender: indexPath)
    }

}
//*** End TableView ***//


//***  SearchBar *** //
extension CustomerViewController: UISearchBarDelegate {
    //-> textDidChange
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resetData()
    }
    
    //-> searchBarTextDidBeginEditing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        self.navigationItem.rightBarButtonItems = []
    }
    
    //-> searchBarCancelButtonClicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        self.navigationItem.rightBarButtonItems = [bbiAdd]
        resetData()
    }
}
//*** End SearchBar *** //

//*** handle protocol **/
extension CustomerViewController: OnUpdatedListener, OnCreatedListener {
    
    //->
    func updateTableRow<T>(data: T, position: Int) {
        guard let customer = data as? CustomerViewDTO else { return }
        self.customers[position] = customer
        tblCustomer.reloadData()
        let indexPath = IndexPath(row: position, section: 0)
        tblCustomer.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    //-> created
    func created() {
        resetData()
    }
}
