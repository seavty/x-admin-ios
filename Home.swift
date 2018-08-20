//
//  Home.swift
//  X-Admin
//
//  Created by SeavTy on 11/27/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit
import WebKit

class Home: UITableViewController {

    @IBOutlet weak var btMenuDrawer: UIBarButtonItem!
    
    fileprivate var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        initializeComponents()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sideMenus()
    {
        if revealViewController() != nil
        {
            btMenuDrawer.target = revealViewController();
            btMenuDrawer.action = #selector(SWRevealViewController.revealToggle(_:)); // or "revealToggle";
            revealViewController().rearViewRevealWidth = 275;
            revealViewController().rightViewRevealWidth = 160;
            
            //btMenuDrawer.action = #selector(SWRevealViewController.rightRevealToggle(_:));
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //print("EmployeeInfo")
    }
    
    
}

//** function **/
extension Home {
    
    //-> initializeComponents
    fileprivate func initializeComponents() {
        setupWebView()
    }
    
    //-> setupWebView
    fileprivate func setupWebView() {
        let myURL = URL(string: ApiHelper.reportURL())
        var myRequest = URLRequest(url: myURL!)
        myRequest.setValue(ApiHelper.getToken(), forHTTPHeaderField: "token")
        myRequest.setValue(ApiHelper.get_Token(), forHTTPHeaderField: "_token")
        webView.load(myRequest)
        print(ApiHelper.getToken());
    }
    
}
//** end function **/

//** WKUIDelegate **//
extension Home: WKUIDelegate {
    
    //-> loadView
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        IndicatorHelper.showIndicator(view: self.view);
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        IndicatorHelper.hideIndicator()
    }
    
    
}
//** end WKUIDelegate **//
