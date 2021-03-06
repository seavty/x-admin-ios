//
//  LoginTableViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/24/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class LoginTableViewController: UITableViewController {

    fileprivate let def = UserDefaults.standard
    
    @IBOutlet var txtUserName: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet weak var lblCompany: UILabel!
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if def.value(forKey: ConstantHelper.COMPANY_NAME) == nil {
            lblCompany.text = "Company Not Found !";
        }else{
            lblCompany.text = def.value(forKey: ConstantHelper.COMPANY_NAME) as? String;
        }
    }
    //-> loginClick
    @IBAction func loginClick(_ sender: UIButton) {
        if isValidated() {
            /*
            let def = UserDefaults.standard
            guard (def.value(forKey: ConstantHelper.BASE_URL) as? String) != nil
                else {
                    //self.navigationController?.view.makeToast("Please configure setting first", duration: 3.0, position: .center)
                    self.def.set(ConstantHelper.DEFALUT_URL,forKey: ConstantHelper.BASE_URL)
                    //return
                    
            }
            handleLogin()
            */
            if def.value(forKey: ConstantHelper.BASE_URL) == nil {
                self.def.set(ConstantHelper.DEFALUT_URL,forKey: ConstantHelper.BASE_URL)
            }else if def.value(forKey: ConstantHelper.REPORT_URL) == nil {
                self.def.set(ConstantHelper.DEFALUT_REPORT_URL,forKey: ConstantHelper.REPORT_URL)
            }
            else {
                handleLogin()
            }
            
            
        }
    }
    
    @IBAction func settingClick(_ sender: UIButton) {
        
    }
}

//*** function  ***//
extension LoginTableViewController {
    
    //-> handleLogin
    fileprivate func handleLogin() {
        do {
            let user = UserLoginDTO()
            user.userName = txtUserName.text
            user.password = txtPassword.text == nil ? "" : txtPassword.text
            
            let url = URL(string: ApiHelper.userEndPoint)!
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            if let db = def.value(forKey: ConstantHelper.CURRENT_DB) as? String {
                request.setValue(db, forHTTPHeaderField: "_token")
            }
            
            request.httpBody = try JSONEncoder().encode(user)
            IndicatorHelper.showIndicator(view: self.view)
            Alamofire.request(request).responseJSON {
                (response) in
                IndicatorHelper.hideIndicator()
                let statusCode = response.response?.statusCode ?? 0
                switch statusCode {
                case 200:
                    guard let data = response.data as Data! else { return }
                    do {
                        let user = try JSONDecoder().decode(UserViewDTO.self, from: data)
                        let setDefaultValue = UserDefaults.standard;
                        setDefaultValue.set(user.token,forKey: ConstantHelper.TOKEN)
                        setDefaultValue.set(user.userProfile?.setting?.warehouse?.id,forKey: ConstantHelper.WAREHOUSE_ID)
                        
                        let storyboard = UIStoryboard(name: ConstantHelper.MAIN_STRORYBOARD, bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: ConstantHelper.MAIN_CONTROLLER)
                        self.present(controller, animated: true, completion: nil)
                        
                    }
                    catch {
                        print(error)
                    }
                case 404:
                    self.navigationController?.view.makeToast("Incorrect user name or password", duration: 3.0, position: .center)
                case 500:
                    self.navigationController?.view.makeToast(ConstantHelper.errorOccurred, duration: 3.0, position: .center)
                default:
                    self.navigationController?.view.makeToast(ConstantHelper.errorOccurred, duration: 3.0, position: .center)
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    //-> validation
    fileprivate func isValidated() -> Bool {
        if(txtUserName.text == "") {
            self.navigationController?.view.makeToast("User name is required", duration: 3.0, position: .center)
            return false
        }
        
        if def.value(forKey: ConstantHelper.COMPANY_NAME) == nil {
            self.navigationController?.view.makeToast("Company Not Found !\nSetup your company in Setting", duration: 3.0, position: .center)
            return false;
        }
        /*
        if(txtPassword.text == "") {
            self.navigationController?.view.makeToast("User name is required", duration: 3.0, position: .center)
            return false
        }
        */
        return true
    }
}
//*** end function ***?/
