//
//  HomeViewController.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/26/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class HomeViewController: UIViewController {

    fileprivate var webView: WKWebView!
    let tokenPicker = UIPickerView()
    
    @IBOutlet weak var txtToken: UITextField!
    let tokenOptions = ["cancel", "discount", "editPrice"]
    fileprivate var selectedPickerRow: Int?
    
    //-> viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
    }
    
    //-> logoutClick
    @IBAction func logoutClick(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "System", message: "Do you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.handleLogout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

//** function **/
extension HomeViewController {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        //setupWebView()
        setupTokenPicker()
    }
    
    //-> setupWebView
    fileprivate func setupWebView() {
        let myURL = URL(string: ApiHelper.homeURL)
        var myRequest = URLRequest(url: myURL!)
        myRequest.setValue(ApiHelper.getToken(), forHTTPHeaderField: "token")
        webView.load(myRequest)
    }
    
    //-> handleLogout
    fileprivate func handleLogout() {
        let storyboard = UIStoryboard(name: ConstantHelper.MAIN_STRORYBOARD, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: ConstantHelper.LOGIN_CONTROLLER)
        self.present(controller, animated: true, completion: nil)
    }
    
    //-> setupTokenPicker
    fileprivate func setupTokenPicker() {
        tokenPicker.delegate = self
        txtToken.inputView = tokenPicker
        setupToolBarForWarehousePicker()
    }
    
    //-> setupToolBarForTokenPicker
    func setupToolBarForWarehousePicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let getTokenButton = UIBarButtonItem(title: "Get Token", style: .done, target: self, action: #selector(HomeViewController.getToken))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(HomeViewController.dimissKeyboard))
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolBar.setItems([getTokenButton, flexible, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        txtToken.inputAccessoryView = toolBar
    }
    
    //-> dimissKeyboard
    @objc func dimissKeyboard() {
        view.endEditing(true)
    }
    
    //->
    @objc func getToken() {
        do {
            let url = ApiHelper.tokenEndPoint
            let token = TokenGetTokenDTO()
            token.isUser = "Y"
            token.toke_CustomerID = 1
            token.toke_Module = "cancel" // -> should be dynamic get from  UI Picker view 
            var request = ApiHelper.getRequestHeader(url: url, method: RequestMethodEnum.post)
            request.httpBody = try JSONEncoder().encode(token)
            IndicatorHelper.showIndicator(view: self.view)
            Alamofire.request(request).responseJSON {
                (response) in
                IndicatorHelper.hideIndicator()
                if  ApiHelper.isSuccessful(vc: self, response: response){
                    print("ok")
                    do {
                        guard let data = response.data as Data! else { return }
                        let json = try JSONDecoder().decode(TokenViewDTO.self, from: data)
                        print(json.toke_Name)
                        AlertHelper().alertMessage(vc: self, message: json.toke_Name!)
                    }
                    catch {
                        self.navigationController?.view.makeToast(ConstantHelper.errorOccurred)
                    }
                    
                }
            }
        }
        catch {
            self.navigationController?.view.makeToast(ConstantHelper.errorOccurred)
        }
       
    }
    
    
}
//** end function  **/


//** WKUIDelegate **//
extension HomeViewController: WKUIDelegate, UIWebViewDelegate {
    
    /*
    //-> loadView
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
     */
}
//** end WKUIDelegate **//



//*** pickerview ***//
extension HomeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    //-> numberOfComponents
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //-> numberOfRowsInComponent
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tokenOptions.count
    }
    
    //-> titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tokenOptions[row]
    }
    
    //-> didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //selectedPickerRow = row
        //var displayText =
        txtToken.text = tokenOptions[row]
        
    }
}
//*** end pickerviewr ***//
