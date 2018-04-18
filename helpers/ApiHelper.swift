//
//  ApiHelper.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/3/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import Alamofire

final class ApiHelper {
    fileprivate let getDefaultValue = UserDefaults.standard
    
    static let customerEndPoint = apiURL() + "customers/"
    
    //-> apiURL()
    static func apiURL() -> String {
        //guard let URL = getDefaultValue.value(forKey: "IP") as! String? else { return "" }
        //return URL + "/api/v1/"
        
        return "http://192.168.0.107/x-admin-api/api/v1/"
    }
    
    //-> getRequestHeader
    static func getRequestHeader(url:String, method:RequestMethodEnum) -> URLRequest{
        let requestURL = URL(string: url)!
        var request = URLRequest(url: requestURL)
        switch method {
        case RequestMethodEnum.get:
            request.httpMethod = HTTPMethod.get.rawValue
        case RequestMethodEnum.post:
            request.httpMethod = HTTPMethod.post.rawValue
        case RequestMethodEnum.put:
            request.httpMethod = HTTPMethod.put.rawValue
        case RequestMethodEnum.delete:
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
    
    //-> isSuccessful
    static func isSuccessful(vc: UIViewController, response: DataResponse<Any>) -> Bool {
        let statusCode = response.response?.statusCode ?? 0
        switch statusCode {
        case 200:
            return true
        case 400:
            do {
                guard let data = response.data as Data! else { return false }
                let json = try JSONDecoder().decode(ErrorDTO.self, from: data)
                vc.navigationController?.view.makeToast(json.message)
            }
            catch {
                vc.view.makeToast(ConstantHelper.errorOccurred)
            }
            return false
        case 401:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Auth")
            vc.present(controller, animated: true, completion: nil)
            return false
        case 404:
            vc.navigationController?.view.makeToast(ConstantHelper.error404)
            return false
        case 500:
            vc.view.makeToast(ConstantHelper.errorOccurred)
            return false
        default:
            vc.view.makeToast(ConstantHelper.errorOccurred)
            return false
        }
    }

}

