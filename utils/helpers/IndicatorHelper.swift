//
//  IndicatorHelper.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/15/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
final class IndicatorHelper {
    public static let sharedInstance = IndicatorHelper()
    
    static fileprivate var overlayView = UIView()
    static fileprivate var label = UILabel()
    static var activityIndicator = UIActivityIndicatorView()
    
    //-> setIndicatorText
    static public func setIndicatorText(str:String) {
        self.label.text = str
        
    }
    
    //-> showIndicator
    static public func showIndicator(view: UIView!) {
        if !activityIndicator.isAnimating {
            //overlayView = UIView(frame: UIScreen.main.bounds)
            overlayView = UIView(frame: view.bounds)
            overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            activityIndicator.center = overlayView.center
            overlayView.addSubview(activityIndicator)
            activityIndicator.color = UIColor.black
            //activityIndicator.activityIndicatorViewStyle = .gray
            //activityIndicator.activityIndicatorViewStyle = .whiteLarge
            activityIndicator.startAnimating()
            label.textColor = UIColor.white
            //label.text = "Loading..."
            label.center = activityIndicator.center
            label.textAlignment = .center
            label.frame = CGRect(x: 0,
                               y: overlayView.center.y, width: overlayView.frame.width, height: 50);
            overlayView.addSubview(label)
            view.addSubview(overlayView)
        }
    }
    
    //-> hideIndicator
    static func hideIndicator() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
