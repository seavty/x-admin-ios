//
//  ItemViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/19/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class ItemViewController: UIViewController {

    @IBOutlet fileprivate var tblItem: UITableView!
    @IBOutlet fileprivate var bbiAdd: UIBarButtonItem!
    
    fileprivate var items = [ItemViewDTO]()
    fileprivate var currentPage = 1
    fileprivate var isEOF = false
    
    fileprivate var refreshControl = UIRefreshControl()
    fileprivate var searchBar = UISearchBar()
    
    fileprivate struct StoryBoardInfo {
        static let tableItemCellIdentifier = "cell"
        static let itemSummarySegue = "ItemSummarySegue"
        static let createItemSegue = "CreateItemSegue"
    }
    
    var isFromReceiveSummaryTableViewController = false
    var selectTableRowListener: OnSelectedTableRowListener?
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }

    //-> addClick
    @IBAction func addClick(_ sender: UIBarButtonItem) {
    }
    
    //-> prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case StoryBoardInfo.createItemSegue? :
            guard let vc = segue.destination as? ItemSummaryTableViewController else {return}
            vc.createdListener = self
        case StoryBoardInfo.itemSummarySegue?:
            guard let vc = segue.destination as? ItemSummaryTableViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            vc.item = items[indexPath.row]
            vc.rowPosition = indexPath.row
            vc.backClickListener = self
        default:
            self.view.makeToast(ConstantHelper.wrongSegueName)
        }
    }
}

//*** function *** //
extension ItemViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        setupNavBar()
        setupTableView()
        setupSearchBar()
        setupRefreshControl()
        self.getItems()
    }
    
    //-> setupNavBar
    fileprivate func setupNavBar() {
        if isFromReceiveSummaryTableViewController {
            navigationItem.rightBarButtonItems = []
        }
        else {
            self.navigationItem.rightBarButtonItems = [bbiAdd]
        }
    }
    
    //-> setupTableView
    fileprivate func setupTableView() {
        tblItem.dataSource = self
        tblItem.delegate = self
    }
    
    //-> setupSearchBar ---//
    fileprivate func setupSearchBar(){
        searchBar.placeholder = "Item Name / Code"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    //-> setupRefreshControl
    fileprivate func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "");
        refreshControl.addTarget(self, action: #selector(ItemViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.tblItem.addSubview(refreshControl)
    }
    
    //-> resetData
    fileprivate func resetData() {
        self.items.removeAll()
        tblItem.reloadData()
        isEOF = false
        currentPage = 1
        getItems()
    }
    
    //-> handleRefresh
    @objc func handleRefresh( refreshControl: UIRefreshControl) {
        resetData()
        refreshControl.endRefreshing()
    }
    //-> handleAdd
    fileprivate func handleAdd() {
        performSegue(withIdentifier: StoryBoardInfo.createItemSegue, sender: self)
    }
    
    //-> deleteItem
    fileprivate func deleteItem(indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        let url = ApiHelper.itemEndPoint + item.id!.toString
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.delete)
        IndicatorHelper.showIndicator(view: self.view)
        Alamofire.request(request).responseJSON {
            (response) in
            IndicatorHelper.hideIndicator()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                self.items.remove(at: indexPath.row)
                self.tblItem.beginUpdates()
                self.tblItem.deleteRows(at: [indexPath], with: .middle)
                self.tblItem.endUpdates()
            }
        }
    }
    
    //-> getItems
    fileprivate func getItems() {
        var url = ApiHelper.itemEndPoint + "?currentPage=" + currentPage.toString
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
                    let json = try JSONDecoder().decode(GetListDTO<ItemViewDTO>.self, from: data)
                    guard let totalPage = json.metaData?.totalPage as Int! else { return }
                    if(self.currentPage <= totalPage) {
                       guard let items = json.results else {return}
                        if items.count > 0 {
                            self.tblItem.beginUpdates()
                            for item in items {
                                self.items.append(item)
                                let indexPath:IndexPath = IndexPath(row:(self.items.count - 1), section:0)
                                self.tblItem.insertRows(at: [indexPath], with: .automatic)
                            }
                            self.tblItem.endUpdates()
                        }
                        self.currentPage += 1
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
//*** end function ***//


//*** TableView *** //
extension ItemViewController: UITableViewDataSource, UITableViewDelegate {
    //-> heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //-> numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    //-> cellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoardInfo.tableItemCellIdentifier, for: indexPath) as! ItemTableViewCell
        if(items.count > 0) {
            cell.setItem(item: items[indexPath.row])
        }
        else {
            self.tblItem.reloadData()
        }
        return cell
    }
    
    //-> willDisplay
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == items.count - 1 && !isEOF {
            getItems()
        }
    }
    
    //-> commit editingStyle
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            deleteItem(indexPath: indexPath)
        }
    }
    
    //-> didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFromReceiveSummaryTableViewController {
            selectTableRowListener?.selectTableRow(data: items[indexPath.row], position: indexPath.row)
            navigationController?.popViewController(animated: true)
        }
        else {
            self.performSegue(withIdentifier: StoryBoardInfo.itemSummarySegue, sender: indexPath)
        }
    }
}
//*** End TableView ***//

//***  SearchBar *** //
extension ItemViewController: UISearchBarDelegate {
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
        //self.navigationItem.rightBarButtonItems = [bbiAdd]
        setupNavBar()
        resetData()
    }
}
//*** End SearchBar *** //


//*** handel protocol **/
extension ItemViewController: OnUpdatedListener, OnCreatedListener {
    
    //-> updateTableRow
    func updateTableRow<T>(data: T, position: Int) {
        guard let item = data as? ItemViewDTO else { return }
        self.items[position] = item
        let indexPath = IndexPath(row: position, section: 0)
        tblItem.reloadRows(at: [indexPath], with: .middle)
        tblItem.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    //-> created
    func created() {
        resetData()
    }
}

