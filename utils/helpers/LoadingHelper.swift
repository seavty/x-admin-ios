//
//  LoadingHelper.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/15/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

final class ActivityIndicatorHelper {
    public static let sharedInstance = ActivityIndicatorHelper()
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var lbl = UILabel();
    /*
    class var sharedInstance: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    */
    
    
    
    public func setText(str:String)
    {
        self.lbl.text = str;
    }
 
    
    public func showLoading(view: UIView!) {
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
    
    
    
    public func hideLoading() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
