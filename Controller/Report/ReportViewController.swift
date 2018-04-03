//
//  ReportViewController.swift
//  X-Admin
//
//  Created by SeavTy on 2/1/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import UIKit
import WebKit
class ReportViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let myURL = URL(string: "https://www.apple.com")
        let myURL = URL(string: "http://192.168.0.3/xpos/mobile/default.aspx?st=1")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}


