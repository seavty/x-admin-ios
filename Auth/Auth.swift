//
//  Auth.swift
//  X-Admin
//
//  Created by SeavTy on 1/15/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Auth: UITableViewController {
    
    //var baseURL = Server().apiURL + "users/"
    var baseURL = CustomeHelper().apiURL() + "users/"
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func btnLogin(_ sender: UIButton) {
        login()
    }
    
    fileprivate func login() {
        if (txtUserName.text!  == "") {
            CustomeHelper().alertMsg(vc: self, message: "User name is required")
            return
        }
        
        /*
        if (txtPassword.text!  == "") {
            GlobalFunc().alertMsg(vc: self, message: "Password is required")
            return
        }
        */
        
        let user = UserModel()
        user.userName = txtUserName.text!
        user.password = txtPassword.text!
        
        let url = URL(string: baseURL)!
        let json = user.toJSONString()!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        LoadingOverlay.shared.showOverlay(view: self.view);
        Alamofire.request(request).responseJSON {
            (response) in
            LoadingOverlay.shared.hideOverlayView();
            let statusCode = response.response?.statusCode
            switch statusCode! {
            case 200:
                print("hello")
                self.result(value: response.result.value!)
                
            case 404:
                CustomeHelper().alertMsg(vc: self, message: "Incorrect user name or password!")
                
            default:
                CustomeHelper().errorWhenRequest(vc: self)
            }
        }
    }
    
    
    func result(value : Any) {
        
        //-  need to refactor seem a lot of redundant
        //- should create one function to decode jason
        
        var json = JSON(value)
        
        let userProfile = UserProfileModel()
        userProfile.id = json["id"].intValue
        userProfile.userName = json["userName"].stringValue
        userProfile.firstName = json["firstName"].stringValue
        userProfile.lastName = json["lastName"].stringValue
        userProfile.gender = json["gender"].stringValue
        userProfile.token = json["token"].stringValue
        
        let settingJason = json["setting"]
        let setting = SettingModel()
        setting.id = settingJason["id"].intValue
        
        let customerJason = settingJason["customer"]
        let customer = CustomerModel()
        customer.id = customerJason["id"].stringValue
        customer.code = customerJason["code"].stringValue
        customer.name = customerJason["name"].stringValue
        customer.phone = customerJason["phone"].stringValue
        customer.address = customerJason["address"].stringValue
        
        let warehouseJson = settingJason["warehouse"]
        let warehouse =  WarehouseModel()
        warehouse.id = warehouseJson["id"].intValue
        warehouse.name = warehouseJson["name"].stringValue
        warehouse.address = warehouseJson["address"].stringValue
        
        
        setting.customer = customer
        setting.warehouse = warehouse
        
        userProfile.setting = setting
        
        
        let setDefaultValue = UserDefaults.standard;
        setDefaultValue.set(userProfile.token,forKey: "token")
        setDefaultValue.set(userProfile.setting.warehouse.id,forKey: "warehouseID")
        
        
        /*
        let getDefaultValue = UserDefaults.standard;
        let getToken = getDefaultValue.value(forKey: "token") as! String?
        let warehouseID = getDefaultValue.value(forKey: "warehouseID") as! Int?
        
        print(getToken)
        print(warehouseID)
        */
        
        self.performSegue(withIdentifier: "main", sender: self)
        
        
    }
}
