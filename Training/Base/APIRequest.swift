//
//  BaseNetWork.swift
//  Training
//
//  Created by ManhLD on 12/30/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


protocol MeetUpResponse {
    init(json: JSON)
}

struct APIMeetUpRequest {
    var name: String
    var path: String
    var method: Alamofire.HTTPMethod
    var header: HTTPHeaders? = nil
    var parameters: [String:Any]? = nil
    var keyValue: String
    var url: String {
        return "http://meetup.rikkei.org/api/v0/" + path
    }

    init(name: String,
         path: String,
         method: Alamofire.HTTPMethod,
         header: HTTPHeaders = [:],
         parameters: [String: Any],
         keyValue: String = "response") {
        self.name = name
        self.path = path
        self.method = method
        self.header = header
        self.parameters = parameters
        self.keyValue = keyValue
        }
    
    func printInfomationRequest() {
        print("Request name :\(name)")
        print("Request url :\(url)")
        print("Request method :\(method)")
        print("Request header :\(header!)")
        print("Request param:\(parameters!)")
        print("Request keyValue :\(keyValue)")
    }
}

