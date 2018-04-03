//
//  CustomerHelper
//  X-Admin
//
//  Created by SeavTy on 1/4/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CustomeHelper {
    
    let getDefaultValue = UserDefaults.standard;
    func alertMsg(vc:UIViewController, message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
        vc.present(alert, animated: true, completion: nil);
    }
    
    func errorWhenRequest(vc:UIViewController) {
        let alert = UIAlertController(title: "System", message: "Error occur while processing your request", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
        vc.present(alert, animated: true, completion: nil);
    }
    
    /*
    func twoDecimal(number: Double) -> String {
        let doubleValue : Double = number
        return String(format:"%.2f", doubleValue)
    }
    */
    
    func showTwoDecimal(number: Double) -> String {
        let doubleValue : Double = number
        return String(format:"%.2f", doubleValue)
        
    }
    
    func getRequestHeader(url:String, method:RequestMethod) -> URLRequest{
        let requestURL = URL(string: url)!
        var request = URLRequest(url: requestURL)
        
        switch method {
        case RequestMethod.get:
            request.httpMethod = HTTPMethod.get.rawValue
        case RequestMethod.post:
            request.httpMethod = HTTPMethod.post.rawValue
        case RequestMethod.put:
            request.httpMethod = HTTPMethod.put.rawValue
        case RequestMethod.delete:
            request.httpMethod = HTTPMethod.delete.rawValue
        }
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        
        let getToken = getDefaultValue.value(forKey: "token") as! String?
        //let getToken = "c2e4e27f-6c59-44d7-952f-a112e4a5f73c" // ip 112 my laptop
        //let getToken = "b8eedc8d-a158-4751-a894-174498461f53" ip 03 work station
        
        var headers = HTTPHeaders()
        headers["token"] = getToken
        headers["Accept"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        return request
    }
    
    func getWarehouseID() -> Int {
        let warehouseID = getDefaultValue.value(forKey: "warehouseID") as! Int?
        return warehouseID!
    }
    
    func apiURL() -> String {
        
        if let url = getDefaultValue.value(forKey: "IP") as! String? {
            return url + "/api/v1/"
        }
        return ""
        
        // in setting type this http://192.168.0.107/x-admin-api
        //return "http://192.168.0.112/x-admin-api/api/v1/"
        //return "http://192.168.0.3/x-admin-api/api/v1/"
    }
    
    func apiBaseURL() -> String {
        let url = getDefaultValue.value(forKey: "IP") as! String?
        return url!
        
        //return "http://192.168.0.112/x-admin-api/"
        //return "http://192.168.0.3/x-admin-api/"
    }
    
    //convert image to base64 format
    func convertImagesToBase64(images: [UIImage]) -> [String] {
        var base64Array = [String]()
        if(images.count == 0) {
            return base64Array
        }
 
        for image in images {
            var imageData: Data?
            imageData = UIImageJPEGRepresentation(image, 0.7)
            base64Array.append(imageData!.base64EncodedString())
        }
        return base64Array
    }
    
    func getSlideShowID() -> Int {
        return -1
    }
}
