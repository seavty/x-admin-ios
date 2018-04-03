//
//  ItemGroupSummary.swift
//  X-Admin
//
//  Created by SeavTy on 12/15/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class ItemGroupSummary: UITableViewController {

    //var baseURL = Server().apiURL + "itemgroups/"
    var baseURL = CustomeHelper().apiURL() + "itemgroups/"
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    var itemGroupWithDocument = ItemGroupWithDocumentModel()
    //*** image ***//
    var mode = Mode.new
    var images = [UIImage]()
    
    struct StoryBoardInfo{
        static let itemGallerySegue = "ItemGallery"
    }
    
    //----------- *** ------------//
    override func viewDidLoad() {
        super.viewDidLoad()
        initComp()
        //print("itemGroupWithDocument viewDidLoad\(itemGroupWithDocument.toJSONString())")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("images viewDidAppear \(images)")
        //print("itemGroupWithDocument viewDidAppear\(itemGroupWithDocument.toJSONString())")
    }
    
    func initComp() {
        barButton.title = "Edit"
        if (itemGroupWithDocument.id == "") {
            barButton.title = "Save"
        }
        else {
            displaySummary()
        }
        
        if(barButton.title == "Edit") {
            mode = Mode.view
        }
    }

    @IBAction func barButtonClick(_ sender: UIBarButtonItem) {
        if barButton.title == "Save" {
            if (itemGroupWithDocument.id == "") {
                newRecord()
            }
            else {
                updateRecord()
            }
        }
        mode = Mode.edit
        barButton.title = "Save"
        enableControl()
    }
    
    // *** crud operation ** //
    
    //-- create
    func newRecord() {
        if (validation() == false) {
            return;
        }
        let itemGroup = ItemGroupWithUploadImagesModel()
        itemGroup.name = txtName.text!
        itemGroup.images = CustomeHelper().convertImagesToBase64(images: images)
        
        var request = CustomeHelper().getRequestHeader(url: baseURL, method: RequestMethod.post)
        let json = itemGroup.toJSONString()!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            (response) in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                if let vc = self.navigationController!.viewControllers[0] as? ItemGroup {
                    vc.isRefresh = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
        
    }
    
    //-- update
    func updateRecord() {
        if (validation() == false) {
            return;
        }
        let itemGroupWithUploadImages = ItemGroupWithUploadImagesModel();
        itemGroupWithUploadImages.id = itemGroupWithDocument.id
        itemGroupWithUploadImages.name = txtName.text!
        
        if(itemGroupWithDocument.documents.count > 0) {
             images.removeSubrange(0..<itemGroupWithDocument.documents.count)
        }
        itemGroupWithUploadImages.images = CustomeHelper().convertImagesToBase64(images: images)
        let url = baseURL + itemGroupWithUploadImages.id
        var request = CustomeHelper().getRequestHeader(url: url, method: RequestMethod.put)
        let json = itemGroupWithUploadImages.toJSONString()!
        
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            (response) in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                if let vc = self.navigationController!.viewControllers[0] as? ItemGroup {
                    vc.isRefresh = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
    
    // *** end  crud operation ** //
    
    func validation() -> Bool {
        if (txtName.text  == "") {
            CustomeHelper().alertMsg(vc: self, message: "Name is required")
            return false
        }
        return true
    }
    
    func disableControl() {
        self.txtName.isEnabled = false
    }
    
    func enableControl() {
        self.txtName.isEnabled = true
    }

    @IBAction func btnImages(_ sender: UIButton) {
        getValueFromControl()
        self.performSegue(withIdentifier: StoryBoardInfo.itemGallerySegue, sender: self)
    }
    
    fileprivate func getValueFromControl() {
        //itemGroup.name = txtName.text!
        itemGroupWithDocument.name = txtName.text!
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case StoryBoardInfo.itemGallerySegue:
            let vc = segue.destination as! ItemGallery
            vc.isFromItemGroup = true
            vc.itemGroupWithDocument = itemGroupWithDocument
            vc.mode = mode
        default:
            print("no segue")
        }
    }
    
    fileprivate func displaySummary() {
        self.txtName.text = itemGroupWithDocument.name
       
    }
}
