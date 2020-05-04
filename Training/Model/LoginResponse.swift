//
//  UpdateModel.swift
//  Training
//
//  Created by ManhLD on 12/31/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import SwiftyJSON


class PostAPIResponse {
    
    var status: Int = 0
    var errorCode: Int = 0
    var errorMessage: String = ""
    
    convenience init(data : JSON) {
        self.init()
        self.status = data["status"].intValue
        self.errorCode = data["error_code"].intValue
        self.errorMessage = data["error_message"].stringValue
    }
}



class LoginAPI : APIMeetUpService<LoginResponse> {
    init(email : String, password : String) {
        super.init(request: APIMeetUpRequest(name: "API00010  Login ",
                                             path: "login",
                                             method: .post,
                                             parameters: ["email" : email, "password" : password]))
    }
}

struct LoginResponse : MeetUpResponse {
    var loginResponse = PostAPIResponse()
    var userToken : String?
    init(json: JSON) {
        let data = json
        userToken = data["response"]["token"].stringValue 
        loginResponse = PostAPIResponse(data: data)
    }
}
