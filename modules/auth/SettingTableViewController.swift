//
//  SettingTableViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/24/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import Alamofire

class SettingTableViewController: UITableViewController {

    fileprivate let def = UserDefaults.standard
    
    @IBOutlet fileprivate var bbiSave: UIBarButtonItem!
    @IBOutlet fileprivate var txtSetting: UITextField!
    @IBOutlet fileprivate var txtReportURL: UITextField!
    
    @IBOutlet weak var txtCompany: UITextField!
    @IBOutlet weak var txtCompanyPassword: UITextField!

    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }
    
    @IBAction func btCompanyLoginClick(_ sender: Any) {
        if isValidated_comp()
        {
            handleLogin();
        }
    }
    //-> saveClick
    @IBAction func saveClick(_ sender: UIBarButtonItem) {
        if isValidated() {
            def.removeObject(forKey: ConstantHelper.BASE_URL)
            self.def.set(txtSetting.text,forKey: ConstantHelper.BASE_URL)
            
            def.removeObject(forKey: ConstantHelper.REPORT_URL)
            self.def.set(txtReportURL.text,forKey: ConstantHelper.REPORT_URL)
            
            def.synchronize()
            navigationController?.popViewController(animated: true)
        }
    }
}


//** function *** //
extension SettingTableViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        if let apiURL = def.value(forKey: ConstantHelper.BASE_URL) as? String
        {
            txtSetting.text = apiURL
        }
        else {
            txtSetting.text = ConstantHelper.DEFALUT_URL;
        }
        
        
        if let reportURL = def.value(forKey: ConstantHelper.REPORT_URL) as? String
        {
            txtReportURL.text = reportURL
        }
        else {
            txtReportURL.text = ConstantHelper.DEFALUT_REPORT_URL;
        }
        
        
    }
    
    //-> validation
    fileprivate func isValidated() -> Bool {
        if(txtSetting.text == "") {
            self.navigationController?.view.makeToast("API URL is required", duration: 3.0, position: .center)
            return false
        }
        
        if(txtReportURL.text == "") {
            self.navigationController?.view.makeToast("Report URL is required", duration: 3.0, position: .center)
            return false
        }
        
        return true
    }
    
    //-> validation
    fileprivate func isValidated_comp() -> Bool {
        
        if(txtSetting.text == "") {
            self.navigationController?.view.makeToast("API URL is required", duration: 3.0, position: .center)
            return false
        }
        
        if(txtCompany.text == "") {
            self.navigationController?.view.makeToast("Company Name is required", duration: 3.0, position: .center)
            return false
        }
        
        if(txtCompanyPassword.text == "") {
            self.navigationController?.view.makeToast("Company Password is required", duration: 3.0, position: .center)
            return false
        }
        
        return true
    }
    
    fileprivate func handleLogin() {
        do {
            let company = CompanyLoginDTO()
            company.user_UserName = txtCompany.text
            company.user_Password = txtCompanyPassword.text == nil ? "" : txtCompanyPassword.text
            
            let url = URL(string: txtSetting.text! + "api/v1/" + "" + ApiHelper.companyEndPoint)!
            print(company);
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(company)
            IndicatorHelper.showIndicator(view: self.view)
            Alamofire.request(request).responseJSON {
                (response) in
                IndicatorHelper.hideIndicator()
                
                let statusCode = response.response?.statusCode ?? 0
                switch statusCode {
                case 200:
                    guard let data = response.data as Data? else { return }
                    do {
                        let company = try JSONDecoder().decode(CompanyLoginDTO.self, from: data)
                        if(company.user_StoreName != ""){
                            let setDefaultValue = UserDefaults.standard;
                            setDefaultValue.set(company.user_DB,forKey: ConstantHelper.CURRENT_DB)
                            setDefaultValue.set(company.user_StoreName,forKey: ConstantHelper.COMPANY_NAME)
                            setDefaultValue.synchronize()
                            self.navigationController?.popViewController(animated: true)
                            self.saveClick(self.bbiSave);
                        }else{
                            self.navigationController?.view.makeToast("Incorrect company name or password", duration: 3.0, position: .center)
                        }
                        
                    }
                    catch {
                        print(error)
                    }
                case 404:
                    self.navigationController?.view.makeToast("Incorrect company name or password", duration: 3.0, position: .center)
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
}
//*** end function ***//
