//
//  AlertHelper.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/11/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation

class AlertHelper {
    
    func alertMessage(vc:UIViewController, message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
        vc.present(alert, animated: true, completion: nil);
    }
    
}
