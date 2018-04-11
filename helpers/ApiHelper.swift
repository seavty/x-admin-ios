//
//  ApiHelper.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/3/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import Alamofire

class ApiHelper {
    let getDefaultValue = UserDefaults.standard;
    
    func apiURL() -> String {
        guard let URL = getDefaultValue.value(forKey: "IP") as! String? else { return "" }
        return URL + "/api/v1/"
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
        
        //let getToken = getDefaultValue.value(forKey: "token") as! String?
        let getToken = "a51a6b33-f844-4bc8-bbbf-d15a3ca97099" // ip 112 my laptop
        var headers = HTTPHeaders()
        headers["token"] = getToken
        headers["Accept"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        return request
    }
    
    func isSuccessful(vc: UIViewController ,statusCode: Int) -> Bool {
        switch statusCode {
        case 200:
            return true
        case 401:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Auth")
            vc.present(controller, animated: true, completion: nil)
            return false
            
        case 500:
            AlertHelper().alertMessage(vc: vc, message: "Error occurred while processing your request! Please try again! ")
            return false
        default:
            AlertHelper().alertMessage(vc: vc, message: "Error occurred while processing your request! Please try again! ")
            return false
        }
        
        
    }

}

