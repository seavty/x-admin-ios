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

    @IBOutlet var txtUserName: UITextField!
    @IBOutlet var txtPassword: UITextField!
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //-> loginClick
    @IBAction func loginClick(_ sender: UIButton) {
        if isValidated() {
            let def = UserDefaults.standard
            guard (def.value(forKey: ConstantHelper.BASE_URL) as? String) != nil
                else {
                    self.navigationController?.view.makeToast("Please configure setting first", duration: 3.0, position: .center)
                    return
                    
            }
            handleLogin()
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
