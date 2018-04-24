//
//  ItemGroupViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/20/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class ItemGroupViewController: UIViewController {

    @IBOutlet fileprivate var tblItemGroup: UITableView!
    @IBOutlet fileprivate var bbiAdd: UIBarButtonItem!
    
    fileprivate var itemGroups = [ItemGroupViewDTO]()
    fileprivate var currentPage = 1
    fileprivate var isEOF = false
    
    fileprivate var refreshControl = UIRefreshControl()
    fileprivate var searchBar = UISearchBar()
    
    fileprivate struct StoryBoardInfo {
        static let tableItemGroupCellIndentifier = "cell"
        static let itemGroupSummarySegue = "ItemGroupSummarySegue"
        static let createItemGroupSegue = "CreateItemGroupSegue"
    }
    
    var isFromItemViewController = false
    var selectTableRowListener: OnSelectedTableRowListener?
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
        print(isFromItemViewController)
    }
    
    //-> addClick
    @IBAction func addClick(_ sender: UIBarButtonItem) {
        handleAdd()
    }
    
    //-> prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case StoryBoardInfo.createItemGroupSegue? :
            guard let vc = segue.destination as? ItemGroupSummaryTableViewController else {return}
            vc.createdListener = self
        case StoryBoardInfo.itemGroupSummarySegue?:
            guard let vc = segue.destination as? ItemGroupSummaryTableViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            vc.itemGroup = itemGroups[indexPath.row]
            vc.rowPosition = indexPath.row
            vc.backClickListener = self
        default:
            self.view.makeToast(ConstantHelper.wrongSegueName)
        }
    }
}

//*** function *** //
extension ItemGroupViewController {
    //-> initializeComponents
    fileprivate func initializeComponents() {
        setupNavBar()
        setupTableView()
        setupSearchBar()
        setupRefreshControl()
        self.getItemGroups()
    }
    
    //-> setupNavBar
    fileprivate func setupNavBar() {
        if isFromItemViewController {
            navigationItem.rightBarButtonItems = []
        }
        else {
            navigationItem.rightBarButtonItems = [bbiAdd]
        }
    }
    
    //-> setupTableView
    fileprivate func setupTableView() {
        tblItemGroup.dataSource = self
        tblItemGroup.delegate = self
    }
    
    //-> setupSearchBar ---//
    fileprivate func setupSearchBar(){
        searchBar.placeholder = "Item group Name"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    //-> setupRefreshControl
    fileprivate func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "");
        refreshControl.addTarget(self, action: #selector(ItemGroupViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        self.tblItemGroup.addSubview(refreshControl)
    }
    
    //-> resetData
    fileprivate func resetData() {
        self.itemGroups.removeAll()
        tblItemGroup.reloadData()
        isEOF = false
        currentPage = 1
        getItemGroups()
    }
    
    //-> handleRefresh
    @objc func handleRefresh( refreshControl: UIRefreshControl) {
        resetData()
        refreshControl.endRefreshing()
    }
    //-> handleAdd
    fileprivate func handleAdd() {
        performSegue(withIdentifier: StoryBoardInfo.createItemGroupSegue, sender: self)
    }
    
    //-> deleteCustomer
    fileprivate func deleteItemGroup(indexPath: IndexPath) {
        let itemGroup = self.itemGroups[indexPath.row]
        let url = ApiHelper.itemGroupEndPoint + itemGroup.id!.toString
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.delete)
        IndicatorHelper.showIndicator(view: self.view)
        Alamofire.request(request).responseJSON {
            (response) in
            IndicatorHelper.hideIndicator()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                self.itemGroups.remove(at: indexPath.row)
                self.tblItemGroup.beginUpdates()
                self.tblItemGroup.deleteRows(at: [indexPath], with: .middle)
                self.tblItemGroup.endUpdates()
            }
        }
    }
    
    //-> getCustomers
    fileprivate func getItemGroups() {
        var url = ApiHelper.itemGroupEndPoint + "?currentPage=" + currentPage.toString
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
                    let json = try JSONDecoder().decode(GetListDTO<ItemGroupViewDTO>.self, from: data)
                    guard let totalPage = json.metaData?.totalPage as Int! else { return }
                    if(self.currentPage <= totalPage) {
                        guard let itemGroups = json.results else {return}
                        if itemGroups.count > 0 {
                            self.tblItemGroup.beginUpdates()
                            for itemGroup in itemGroups {
                                self.itemGroups.append(itemGroup)
                                let indexPath:IndexPath = IndexPath(row:(self.itemGroups.count - 1), section:0)
                                self.tblItemGroup.insertRows(at: [indexPath], with: .automatic)
                            }
                            self.tblItemGroup.endUpdates()
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
//*** end function *** //


//*** TableView *** //
extension ItemGroupViewController: UITableViewDataSource, UITableViewDelegate {
    
    //-> heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //-> numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemGroups.count
    }
    
    //-> cellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoardInfo.tableItemGroupCellIndentifier, for: indexPath) as! ItemGroupTableViewCell
        if(itemGroups.count > 0) {
            cell.setItemGroup(itemGroup: itemGroups[indexPath.row])
        }
        else {
            self.tblItemGroup.reloadData()
        }
        return cell
    }
    
    //-> willDisplay
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == itemGroups.count - 1 && !isEOF {
            getItemGroups()
        }
    }
    
    //-> commit editingStyle
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            deleteItemGroup(indexPath: indexPath)
        }
    }
    
    //-> didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFromItemViewController {
            selectTableRowListener?.selectTableRow(data: itemGroups[indexPath.row], position: indexPath.row)
            navigationController?.popViewController(animated: true)
        }
        else {
            self.performSegue(withIdentifier: StoryBoardInfo.itemGroupSummarySegue, sender: indexPath)
        }
    }
}
//*** End TableView ***//


//***  SearchBar *** //
extension ItemGroupViewController: UISearchBarDelegate {
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
extension ItemGroupViewController: OnUpdatedListener, OnCreatedListener {
    
    //->
    func updateTableRow<T>(data: T, position: Int) {
        guard let itemGroup = data as? ItemGroupViewDTO else { return }
        self.itemGroups[position] = itemGroup
        tblItemGroup.reloadData()
        let indexPath = IndexPath(row: position, section: 0)
        tblItemGroup.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    //-> created
    func created() {
        resetData()
    }
}
