//
//  ApiHelper.swift
//  X-Admin
//
//  Created by BunEav Ros on 4/3/18.
//  Copyright © 2018 SeavTy. All rights reserved.
//

import Foundation
import Alamofire
import Toast_Swift

final class ApiHelper {
    fileprivate static let getDefaultValue = UserDefaults.standard
    
    static let customerEndPoint = apiURL() + "customers/"
    static let itemEndPoint = apiURL() + "items/"
    static let itemGroupEndPoint = apiURL() + "itemgroups/"
    static let receiveEndPoint = apiURL() + "receives/"
    static let issueEndPoint = apiURL() + "issues/"
    static let userEndPoint = apiURL() + "users/"
    static let companyEndPoint = "companies/"
    
    static let documentEndPoint = apiURL() + "documents/"
    static let warehouseEndPoint = apiURL() + "warehouses/"
    static let tokenEndPoint = apiURL() + "token/"
    
    static let homeURL = "http://xware-kh.com/Home/Default.aspx"
    //static let reportURL = "http://xware-kh.com/Home/Default.aspx"
    
    fileprivate static let xwareURL = "http://xware-kh.com/Home/Default.aspx"
    
    
    //-> reportURL
    static func reportURL() -> String {
        guard let url = getDefaultValue.value(forKey: ConstantHelper.REPORT_URL) as? String else { return xwareURL }
        return url
    }
    
    
    //-> apiBaseURL
    static func apiBaseURL() -> String {
        guard let url = getDefaultValue.value(forKey: ConstantHelper.BASE_URL) as? String else {return ""}
        return url
        //return "http://192.168.0.111/x-admin-api/" //for upload no /api/v1
    }
    
    //-> apiURL()
    static func apiURL() -> String {
        guard let URL = getDefaultValue.value(forKey: ConstantHelper.BASE_URL) as! String? else { return "" }
        return URL + "/api/v1/"
        //return "http://192.168.0.111/x-admin-api/api/v1/"
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
        
        guard let token = getDefaultValue.value(forKey: ConstantHelper.TOKEN) as? String else {return request }
        //let token = "64b32fca-5c0d-4656-8469-c207749381dc" // ip 112 my laptop
        var headers = HTTPHeaders()
        headers["token"] = token
        headers["Accept"] = "application/json"
        guard let db = getDefaultValue.value(forKey: ConstantHelper.CURRENT_DB) as? String else {return request }
        //print("db=\(db)")
        headers["_token"] = db;
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
                vc.navigationController?.view.makeToast(json.message, duration: 3.0, position: .center)
            }
            catch {
               vc.view.makeToast(ConstantHelper.error404, duration: 3.0, position: .center)
            }
            return false
        case 401:
            let storyboard = UIStoryboard(name: ConstantHelper.MAIN_STRORYBOARD, bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: ConstantHelper.LOGIN_CONTROLLER)
            vc.present(controller, animated: true, completion: nil)
            return false
        case 404:
            vc.navigationController?.view.makeToast(ConstantHelper.error404, duration: 3.0, position: .center)
            return false
        case 500:
            vc.view.makeToast(ConstantHelper.errorOccurred)
            print(response)
            return false
        default:
            vc.view.makeToast(ConstantHelper.errorOccurred, duration: 3.0, position: .center)
            return false
        }
    }
    
    //-> getWarehouseID
    static func getWarehouseID() -> Int {
        guard let warehouseID = getDefaultValue.value(forKey: ConstantHelper.WAREHOUSE_ID) as! Int? else {return 0}
        return warehouseID
        
    }
    
    //-> getToken
    static func getToken() -> String {
        guard let token = getDefaultValue.value(forKey: ConstantHelper.TOKEN) as! String? else {return ""}
        return token
    }
    
    //-> getToken
    static func get_Token() -> String {
        guard let token = getDefaultValue.value(forKey: ConstantHelper.CURRENT_DB) as! String? else {return ""}
        return token
    }
}

