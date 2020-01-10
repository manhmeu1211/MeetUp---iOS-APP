//
//  NewsItemViewModel.swift
//  Training
//
//  Created by ManhLD on 12/10/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift


class getDataService {
    
    let realm = try! Realm()
    let baseURL = "http://meetup.rikkei.org/api/v0/"
    
    static let getInstance: getDataService = {
        let instance = getDataService()
        return instance
    }()


    
    func register(params: [String : String], completionHandler : @escaping (JSON?, Int) -> ()) {
        printInfomationRequest(name: "API00013  Register", url: baseURL + "register", method: .post, header: nil, parameters: params, keyValue: "response")
        Alamofire.request(baseURL + "register", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(let value):
            let response = JSON(value)
            let data = response["response"]
            completionHandler(data, 1)
            case .failure( _):
            completionHandler(nil, 0)
            }
        }
    }
    
    func login(params : [String : String], completionHandler : @escaping (JSON?, Int) -> ()) {
        printInfomationRequest(name: "API00012  Login", url: baseURL + "login", method: .post, header: nil, parameters: params, keyValue: "response")
        Alamofire.request(baseURL + "login", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(let value):
            let response = JSON(value)
            let status = response["status"].intValue
            var data = response["response"]
            if status == 0 {
                data = response["error_message"]
                completionHandler(data, 1)
            } else {
                data = response["response"]
                completionHandler(data, 2)
            }
            case .failure( _):
            completionHandler(nil, 0)
            }
        }
    }
    
    func resetPassword(params : [String : String], completionHandler : @escaping (JSON?, Int) -> ()) {
           printInfomationRequest(name: "API00011  Reset password", url: baseURL + "resetPassword", method: .post, header: nil, parameters: params, keyValue: "response")
        Alamofire.request(baseURL + "resetPassword", method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseJSON { (response) in
             switch response.result {
                case .success(let value):
                let response = JSON(value)
                let status = response["status"]
                var data = response["response"]
                if status == 0 {
                    data = response["error_message"]
                    completionHandler(data, 1)
                } else {
                    data = response["response"]
                    completionHandler(data, 2)
                }
                case .failure( _):
                completionHandler(nil, 0)
            }
        }
    }
    
    func doUpdateEvent(params : [String : Any], headers : HTTPHeaders, completionHandler : @escaping(JSON?, Int) -> ()) {
        printInfomationRequest(name: "API00010  Do Update Event ", url: baseURL + "doUpdateEvent", method: .post, header: headers, parameters: params, keyValue: "response")
        Alamofire.request(baseURL + "doUpdateEvent", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
              switch response.result {
                case .success(let value):
                let response = JSON(value)
                let status = response["status"]
                if status == 0 {
                    let data = response["error_message"]
                    completionHandler(data, 1)
                } else {
                    completionHandler(status, 2)
                }
                case .failure( _):
                completionHandler(nil, 0)
            }
        }
    }
    
    
    func printInfomationRequest(name: String, url : String, method : HTTPMethod, header : [String : Any]? = nil, parameters : [String : Any]? = nil, keyValue : String) {
        print("Request name : \(name)")
        print("Request url : \(url)")
        print("Request method : \(method)")
        print("Request header : \(String(describing: header))")
        print("Request params :", parameters!)
        print("Request keyValue : \(keyValue)")
    }
}
