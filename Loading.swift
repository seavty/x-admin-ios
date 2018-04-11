//
//  Loading.swift
//  X-Admin
//
//  Created by SeavTy on 12/4/17.
//  Copyright © 2017 SeavTy. All rights reserved.
//

import UIKit
import Foundation


public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var lbl = UILabel();
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func setText(str:String)
    {
        //DispatchQueue.main.async(execute: {
        self.lbl.text = str;
        //});
    }
    
    public func showOverlay(view: UIView!) {
        //overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        lbl.textColor = UIColor.white;
        lbl.text = "Loading...";
        lbl.center = activityIndicator.center;
        lbl.textAlignment = .center;
        lbl.frame = CGRect(x: 0,
                           y: overlayView.center.y, width: overlayView.frame.width, height: 50);
        overlayView.addSubview(lbl);
        view.addSubview(overlayView)
    }
    
    
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}

