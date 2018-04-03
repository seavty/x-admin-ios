//
//  ReceiveSubmit.swift
//  X-Admin
//
//  Created by SeavTy on 1/12/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ReceiveSubmit: UITableViewController {

    //var baseURL = Server().apiURL + "issues/"
    
    
    @IBOutlet weak var txtRemarks: UITextView!
    var itemModels = [ItemModel]()
    
    var isFromIssueVC:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("isFromIssueVC \(isFromIssueVC)")
    }

    @IBAction func btnSubmit(_ sender: UIBarButtonItem) {
        
        let receiveIssueModel = ReceiveIssueModel()
        receiveIssueModel.warehouseID = CustomeHelper().getWarehouseID()
        receiveIssueModel.remarks = txtRemarks.text!
        receiveIssueModel.items = self.itemModels
        
        var baseURL = ""
        if(isFromIssueVC) {
            //baseURL = Server().apiURL + "issues/"
            baseURL = CustomeHelper().apiURL() + "issues/"
        }
        else {
            //baseURL = Server().apiURL + "receives/"
            baseURL = CustomeHelper().apiURL() + "receives/"
        }
        
       
        var request = CustomeHelper().getRequestHeader(url: baseURL, method: RequestMethod.post)
        let json = receiveIssueModel.toJSONString()!
        
        print(json)
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            (response) in
            
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                
                //-- will need to remove repate code
                if(self.isFromIssueVC) {
                    guard let vc = self.navigationController!.viewControllers[0] as? Issue else {return}
                    vc.itemModels.removeAll()
                    vc.isRefresh = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
                else {
                    guard let vc = self.navigationController!.viewControllers[0] as? Receive else {return}
                    vc.itemModels.removeAll()
                    vc.isRefresh = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
                
                /*
                if let vc = self.navigationController!.viewControllers[0] as? Issue {
                    vc.itemModels.removeAll()
                    vc.isRefresh = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }*/
            
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
}
