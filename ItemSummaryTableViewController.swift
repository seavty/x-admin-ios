//
//  ItemSummaryTableViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/20/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class ItemSummaryTableViewController: UITableViewController {
    
    @IBOutlet fileprivate var bbiCancel: UIBarButtonItem!
    @IBOutlet fileprivate var bbiSave: UIBarButtonItem!
    @IBOutlet fileprivate var bbiEdit: UIBarButtonItem!
    @IBOutlet var btnPicture: UIButton!
    
    @IBOutlet fileprivate var txtName: UITextField!
    @IBOutlet fileprivate var txtCode: UITextField!
    @IBOutlet fileprivate var txtDescription: UITextField!
    @IBOutlet fileprivate var txtPrice: UITextField!
    
    @IBOutlet fileprivate var btnItemGroup: UIButton!
    var item = ItemViewDTO()
    var rowPosition = -1
    var backClickListener: OnUpdatedListener?
    var createdListener: OnCreatedListener?
    
    fileprivate var isEdited = false
    
    fileprivate struct StoryBoardInfo {
        static let itemGroupSegue = "ItemGroupViewControllerSegue"
        static let itemGallerySegue = "ItemGallery"
    }
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }

    //-> cancelClick
    @IBAction func cancelClick(_ sender: UIBarButtonItem) {
        handCancel()
    }
    
    //-> saveClick
    @IBAction func saveClick(_ sender: UIBarButtonItem) {
        handleSave()
    }
    
    //-> editClick
    @IBAction func editClick(_ sender: UIBarButtonItem) {
         handleEdit()
    }
    @IBAction func itemGroupClick(_ sender: UIButton) {
        print("item group click")
        //performSegue(withIdentifier: StoryBoardInfo.itemGroupSegue, sender: self)
    }
    
    //-> prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case StoryBoardInfo.itemGroupSegue?:
            guard let vc = segue.destination as? ItemGroupViewController else {return}
            vc.isFromItemViewController = true
            vc.selectTableRowListener = self
        case StoryBoardInfo.itemGallerySegue?:
            guard let vc = segue.destination as? ItemGalleryCollectionViewController else {return}
            vc.item = item
            
        default:
            self.view.makeToast(ConstantHelper.wrongSegueName)
        }
    }
}

//*** table view *** //
extension ItemSummaryTableViewController {
    
    //-> willDisplayHeaderView
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Arial", size: 16)
        header.textLabel?.text? = header.textLabel?.text?.capitalized ?? ""
    }
}
//***  end table view *** //


//*** function  *** /
extension ItemSummaryTableViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        btnItemGroup.contentHorizontalAlignment = .left
        setupNavBar()
        if(rowPosition > -1) {
            setupData()
        }
        else {
            txtName.becomeFirstResponder()
        }
    }
    
    //-> setupNavBar
    fileprivate func setupNavBar() {
        navigationItem.rightBarButtonItems = []
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CustomerSummaryTableViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        if(rowPosition == -1) {
            self.navigationItem.rightBarButtonItems = [self.bbiSave]
        }
    }
    
    //-> back
    @objc func back(sender: UIBarButtonItem) {
        if(isEdited) {
            backClickListener?.updateTableRow(data: item, position: rowPosition)
        }
        navigationController?.popViewController(animated: true)
    }
    
    //-> setupData
    fileprivate func setupData(){
        IndicatorHelper.showIndicator(view: self.view)
        let url = ApiHelper.itemEndPoint + "\(self.item.id!)"
        
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.get)
        Alamofire.request(request).responseJSON {
            (response) in
            IndicatorHelper.hideIndicator()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                do {
                    self.navigationItem.rightBarButtonItems = [self.bbiEdit]
                    guard let data = response.data as Data! else { return }
                    let json = try JSONDecoder().decode(ItemViewDTO.self, from: data)
                    self.item.name = json.name
                    self.item.code = json.code
                    self.item.description = json.description
                    self.item.price = json.price
                    self.item.itemGroup = json.itemGroup
                    
                    self.displayData()
                }
                catch {
                    self.navigationItem.rightBarButtonItems = []
                    self.navigationController?.view.makeToast(ConstantHelper.errorOccurred)
                }
            }
        }
    }
    
    //-> displayData
    fileprivate func displayData() {
        txtName.text = item.name
        txtCode.text = item.code
        txtDescription.text = item.description
        txtPrice.text = item.price?.to2Decimal
        btnItemGroup.setTitle(item.itemGroup?.name, for: .normal)
        enableComponents()
    }
    
    //-> enableComponents
    fileprivate func enableComponents(isEnable:Bool = true ) {
        txtName.isEnabled = !isEnable
        txtCode.isEnabled = !isEnable
        txtDescription.isEnabled = !isEnable
        txtPrice.isEnabled = !isEnable
        btnItemGroup.isEnabled = !isEnable
        btnPicture.isEnabled = !(!isEnable)
    }
    
    //-> handleEdit
    fileprivate func handleEdit() {
        navigationItem.rightBarButtonItems = []
        navigationItem.rightBarButtonItems = [bbiSave, bbiCancel]
        enableComponents(isEnable: false)
        txtName.becomeFirstResponder()
    }
    
    //-> handleSave
    fileprivate func handleSave() {
        if(isValidated()) {
            do {
                let item = ItemEditDTO()
                var url = ApiHelper.itemEndPoint
                var requestMethod = RequestMethodEnum.post
                if(rowPosition > -1) {
                    item.id = self.item.id
                    url = url + self.item.id!.toString
                    requestMethod = RequestMethodEnum.put
                }
                item.itemGroup = self.item.itemGroup
                item.name = txtName.text!
                item.code = txtCode.text!
                item.description = txtDescription.text!
                item.price = txtPrice.text!.toDouble
                
                var request = ApiHelper.getRequestHeader(url: url, method: requestMethod)
                request.httpBody = try JSONEncoder().encode(item)
                //print(String(data: try JSONEncoder().encode(item), encoding: .utf8)!)
                IndicatorHelper.showIndicator(view: self.view)
                Alamofire.request(request).responseJSON {
                    (response) in
                    IndicatorHelper.hideIndicator()
                    if  ApiHelper.isSuccessful(vc: self, response: response){
                        self.isEdited = true
                        if(self.rowPosition > -1) {
                            self.setupData()
                        }
                        else {
                            self.createdListener?.created()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            catch {
                self.navigationController?.view.makeToast(ConstantHelper.errorOccurred)
            }
        }
    }
    
    //-> handCancel
    fileprivate func handCancel() {
        /*
        navigationItem.rightBarButtonItems = []
        navigationItem.rightBarButtonItems = [bbiEdit]
        self.displayData()
        */
        setupData()
    }
    
    //-> validation
    fileprivate func isValidated() -> Bool {
        //--since I could not find the best solution to address this validation issue so that temporary I will this way first
        if(txtName.text == "") {
            self.navigationController?.view.makeToast("Name is required", duration: 3.0, position: .center)
            return false
        }
        else if(txtCode.text == "") {
            self.navigationController?.view.makeToast("Code is required", duration: 3.0, position: .center)
            return false
        }
        else if(txtPrice.text == "") {
            self.navigationController?.view.makeToast("Price is required", duration: 3.0, position: .center)
            return false
        }
        
        return true
    }
}
//*** end function  ***//

//*** handle protocol ***/
extension ItemSummaryTableViewController: OnSelectedTableRowListener {
    
    //-> selectTableRow
    func selectTableRow<T>(data: T, position: Int) {
        guard let itemGroup = data as? ItemGroupViewDTO else {return}
        self.item.itemGroup = itemGroup
        btnItemGroup.setTitle(itemGroup.name, for: .normal)
    }
}

//*** end handle protocol ***//
