//
//  ItemGroupSummaryTableViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/20/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class ItemGroupSummaryTableViewController: UITableViewController {

    @IBOutlet fileprivate var bbiCancel: UIBarButtonItem!
    @IBOutlet fileprivate var bbiSave: UIBarButtonItem!
    @IBOutlet fileprivate var bbiEdit: UIBarButtonItem!
   
    @IBOutlet var txtName: UITextField!
    
    @IBOutlet var btnPicture: UIButton!
    
    var itemGroup = ItemGroupViewDTO()
    var rowPosition = -1
    var backClickListener: OnUpdatedListener?
    var createdListener: OnCreatedListener?
    
    fileprivate var isEdited = false
    
    fileprivate struct StoryboardInfo {
        static let itemGroupGallerySegue = "ItemGroupGallery"
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
    
    //-> EditClick
    @IBAction func EditClick(_ sender: UIBarButtonItem) {
        handleEdit()
    }
    
    
    //-> prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case StoryboardInfo.itemGroupGallerySegue?:
            guard let vc = segue.destination as? ItemGalleryCollectionViewController else {return}
            vc.isFromItemGroupController = true
            vc.itemGroup = itemGroup
        default:
            self.view.makeToast(ConstantHelper.wrongSegueName)
        }
    }
    
    
}

//*** function  *** /
extension ItemGroupSummaryTableViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        setupNavBar()
        if(rowPosition > -1) {
            setupData()
            btnPicture.isHidden = false
        }
        else {
            btnPicture.isHidden = true
            txtName.becomeFirstResponder()
        }
    }
    
    //-> setupNavBar
    fileprivate func setupNavBar() {
        navigationItem.rightBarButtonItems = []
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ItemGroupSummaryTableViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        if(rowPosition == -1) {
            self.navigationItem.rightBarButtonItems = [self.bbiSave]
        }
        
        
    }
    
    //-> back
    @objc func back(sender: UIBarButtonItem) {
        if(isEdited) {
            backClickListener?.updateTableRow(data: itemGroup, position: rowPosition)
        }
        navigationController?.popViewController(animated: true)
    }
    
    //-> setupData
    fileprivate func setupData(){
        IndicatorHelper.showIndicator(view: self.view)
        let url = ApiHelper.itemGroupEndPoint + "\(self.itemGroup.id!)"
        
        let request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.get)
        Alamofire.request(request).responseJSON {
            (response) in
            IndicatorHelper.hideIndicator()
            if  ApiHelper.isSuccessful(vc: self, response: response){
                do {
                    self.navigationItem.rightBarButtonItems = [self.bbiEdit]
                    guard let data = response.data as Data! else { return }
                    let json = try JSONDecoder().decode(ItemGroupViewDTO.self, from: data)
                    self.itemGroup.name = json.name
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
        txtName.text = itemGroup.name
        enableComponents()
    }
    
    //-> enableComponents
    fileprivate func enableComponents(isEnable:Bool = true ) {
        txtName.isEnabled = !isEnable
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
                let itemGroup = ItemGroupEditDTO()
                var url = ApiHelper.itemGroupEndPoint
                var requestMethod = RequestMethodEnum.post
                if(rowPosition > -1) {
                    itemGroup.id = self.itemGroup.id
                    url = url + "\(self.itemGroup.id!)"
                    requestMethod = RequestMethodEnum.put
                }
                itemGroup.name = txtName.text!
                
                var request = ApiHelper.getRequestHeader(url: url, method: requestMethod)
                request.httpBody = try JSONEncoder().encode(itemGroup)
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
        setupData()
    }
    
    //-> validation
    fileprivate func isValidated() -> Bool {
        //--since I could not find the best solution to address this validation issue so that temporary I will this way first
        if(txtName.text == "") {
            self.navigationController?.view.makeToast("Name is required", duration: 3.0, position: .center)
            return false
        }
        return true
    }
}


//*** table view *** //
extension ItemGroupSummaryTableViewController {
    
    //-> willDisplayHeaderView
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Arial", size: 16)
        header.textLabel?.text? = header.textLabel?.text?.capitalized ?? ""
    }
}
//***  end table view *** //


