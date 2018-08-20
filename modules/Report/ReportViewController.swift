//
//  ReportViewController.swift
//  X-Admin
//
//  Created by SeavTy on 2/1/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import WebKit

class ReportViewController: UIViewController,UIWebViewDelegate {

    fileprivate var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeComponents()
        
    }
    
}

//** function **/
extension ReportViewController {
    
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
extension ReportViewController: WKUIDelegate {
    
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

