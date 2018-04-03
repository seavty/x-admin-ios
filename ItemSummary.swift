//
//  ItemSummary.swift
//  X-Admin
//
//  Created by SeavTy on 12/14/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ItemSummary: UITableViewController {
    //var baseURL = Server().apiURL + "items/"
    var baseURL = CustomeHelper().apiURL() + "items/"
    
    @IBOutlet weak var txtItemGroup: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    var itemModel = ItemModel()
    var isReload:Bool = false
    var isEditMode:Bool = false
    
    //** image ***//
    var mode = Mode.new
    var imageGallery = [UIImage]()
    
    struct StoryBoardInfo{
        static let itemGallerySegue = "ItemGallery"
    }
    
    //----------- *** ------------//
    override func viewDidLoad() {
        super.viewDidLoad()
        initComp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isReload){
            displaySummary()
        }
        //print("imageGallery \(imageGallery)")
    }
    
    
    fileprivate func initComp() {
        barButton.title = "Edit"
        if(itemModel.id ==  "") {
            barButton.title = "Save"
        }
        else {
            loadSummary()
        }
        
        if(barButton.title == "Edit") {
            mode = Mode.view
        }
        
        
        txtItemGroup.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        //txtItemGroup.addTarget(self, action: #selector(myTargetFunction), for: .allEvents)
        
        
    }
    
    @IBAction func barItemClick(_ sender: UIBarButtonItem) {
        if barButton.title == "Save" {
            if (itemModel.id == "") {
                newRecord()
            }
            else {
                mode = Mode.edit
                updateRecord()
            }
        }
        
        mode = Mode.edit
        
        barButton.title = "Save"
        enableControl()
    }
    
    // *** crud operation ** //
    
    //-- create
    fileprivate func newRecord() {
        if (validation() == false) {
            return;
        }
        
        let model = ItemModel();
        model.code = txtCode.text!
        model.name = txtName.text!
        model.description = txtDescription.text!
        model.price = (txtPrice.text! as NSString).doubleValue
        model.itemGroup.id = self.itemModel.itemGroup.id
        model.itemGroup.name = self.itemModel.itemGroup.name
        
        
        //--upload image to server
        model.images = convertImageToBase64()
        
        var request = CustomeHelper().getRequestHeader(url: baseURL, method: RequestMethod.post)
        let json = model.toJSONString()!
        
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            (response) in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            //print("// -- *** // ")
            //print(statusCode)
            switch statusCode! {
            case 200:
                if let vc = self.navigationController!.viewControllers[0] as? Item {
                    vc.isRefresh = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            case 400:
                if let value = response.result.value {
                    let json = JSON(value)
                    let msg = json["Message"].stringValue
                    CustomeHelper().alertMsg(vc: self, message: msg)
                }
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
    
    //-- read
    fileprivate func loadSummary() {
        disableControl()
        
        let url = baseURL + itemModel.id
        let request = CustomeHelper().getRequestHeader(url: url, method: RequestMethod.get)
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            response in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                if let value = response.result.value {
                    // should create function that map or decode jason
                    // do not write like this, bad practice
                    let json = JSON(value)
                    let model = ItemModel()
                    model.id = json["id"].stringValue
                    model.code = json["code"].stringValue
                    model.name = json["name"].stringValue
                    model.description = json["description"].stringValue
                    model.price = json["price"].doubleValue
                    
                    let itemgroupModel = ItemGroupModel()
                    itemgroupModel.id = json["itemGroup"]["id"].stringValue
                    itemgroupModel.name = json["itemGroup"]["name"].stringValue
                    model.itemGroup = itemgroupModel
                    
                    let documentJson = json["documents"]
                    
                    var documents = [DocumentModel]()
                    
                    for i in 0 ..< documentJson.count {
                        let document = DocumentModel()
                        document.id = documentJson[i]["id"].intValue
                        document.name = documentJson[i]["name"].stringValue
                        document.path = documentJson[i]["path"].stringValue
                        documents.append(document)
                    }
                    model.documents = documents
                    self.itemModel = model
                    self.displaySummary()
                }
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
    
    //-- display summary()
    fileprivate func displaySummary() {
        self.txtCode.text = itemModel.code
        self.txtName.text = itemModel.name
        self.txtDescription.text = itemModel.description
        self.txtItemGroup.text = itemModel.itemGroup.name
        self.txtPrice.text = String(itemModel.price)
    }
    
    //-- update
    fileprivate func updateRecord() {
        //create new record & update record code similar need to refactor it
        if (validation() == false) {
            return;
        }
        
        let model = ItemModel();
        model.id = itemModel.id
        model.code = txtCode.text!
        model.name = txtName.text!
        model.description = txtDescription.text!
        model.price = (txtPrice.text! as NSString).doubleValue
        model.itemGroup.id = self.itemModel.itemGroup.id
        model.itemGroup.name = self.itemModel.itemGroup.name
        
        model.images = convertImageToBase64()
        
        let url = baseURL + model.id
        var request = CustomeHelper().getRequestHeader(url: url, method: RequestMethod.put)
        let json = model.toJSONString()!
        
        //print("updating data \(json)")
        
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            (response) in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            
            switch statusCode! {
            case 200:
                if statusCode == 200 {
                    if let vc = self.navigationController!.viewControllers[0] as? Item {
                        vc.isRefresh = true
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
            case 400:
                if let value = response.result.value {
                    let json = JSON(value)
                    let msg = json["Message"].stringValue
                    
                    CustomeHelper().alertMsg(vc: self, message: msg)
                }
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
        
    }
    
    fileprivate func convertImageToBase64() -> [String] {
        var base64Array = [String]()
        if(mode == Mode.edit) {
            if(itemModel.documents.count > 0) {
                imageGallery.removeSubrange(0..<itemModel.documents.count)
            }
        }
        for image in imageGallery {
            var imageData: Data?
            imageData = UIImageJPEGRepresentation(image, 0.5)
            base64Array.append(imageData!.base64EncodedString())
        }
        return base64Array
    }
    // *** end crud operation ** //
    
    fileprivate func validation() -> Bool {
        if (self.itemModel.itemGroup.id  == "") {
            CustomeHelper().alertMsg(vc: self, message: "Item group is required")
            return false
        }
        
        if (txtName.text  == "") {
            CustomeHelper().alertMsg(vc: self, message: "Item name is required")
            return false
        }
        
        if (txtCode.text  == "") {
            CustomeHelper().alertMsg(vc: self, message: "Item code is required")
            return false
        }
        
        if (txtPrice.text  == "") {
            CustomeHelper().alertMsg(vc: self, message: "Price is required")
            return false
        }
        return true
        
    }
    
    
    fileprivate func disableControl() {
        self.txtItemGroup.isEnabled = false
        self.txtCode.isEnabled = false
        self.txtName.isEnabled = false
        self.txtDescription.isEnabled = false
    }
    
    fileprivate func enableControl() {
        self.txtItemGroup.isEnabled = true
        self.txtCode.isEnabled = true
        self.txtName.isEnabled = true
        self.txtDescription.isEnabled = true
    }
    
    @objc func myTargetFunction() {
        print("It works!")
        getValueFromControl()
        self.performSegue(withIdentifier: "ItemGroupCheckbox", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "ItemGroupCheckbox":
            let vc = segue.destination as! ItemGroupCheckbox
            vc.itemModel = itemModel
        case StoryBoardInfo.itemGallerySegue:
            let vc = segue.destination as! ItemGallery
            vc.item = itemModel
            vc.mode = mode
        default:
            print("no segue")
        }
    }

    @IBAction func btnImage(_ sender: UIButton) {
        getValueFromControl()
        self.performSegue(withIdentifier: StoryBoardInfo.itemGallerySegue, sender: self)
    }
    
    fileprivate func getValueFromControl() {
        itemModel.code = txtCode.text!
        itemModel.name = txtName.text!
        itemModel.description = txtDescription.text!
        itemModel.price = (txtPrice.text! as NSString).doubleValue
    }
    
}
