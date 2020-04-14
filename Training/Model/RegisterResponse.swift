//
//  RegisterResponse.swift
//  Training
//
//  Created by ManhLD on 1/13/20.
//  Copyright © 2020 ManhLD. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class RegisterAPI : APIMeetUpService<RegisterResponse> {
    init(email : String, password : String, fullname : String) {
        super.init(request: APIMeetUpRequest(name: "API00012  Register ",
                                             path: "register",
                                             method: .post,
                                             parameters: ["email" : email, "password" : password, "name" : fullname]))
    }
}

struct RegisterResponse : MeetUpResponse {
    var registerResponse = PostAPIResponse()
    var userToken : String?
    init(json: JSON) {
        let data = json
        userToken = data["respons"]["token"].stringValue ?? ""
        registerResponse = PostAPIResponse(data: data)
    }
}



class ResetPassAPI : APIMeetUpService<ResetPassResponse> {
    init(email : String) {
        super.init(request: APIMeetUpRequest(name: "API00013  Resetpass ",
                                             path: "resetPassword",
                                             method: .post,
                                             parameters: ["email" : email]))
    }
}

struct ResetPassResponse : MeetUpResponse {
    var resetPassResponse = PostAPIResponse()
    init(json: JSON) {
        let data = json
        resetPassResponse = PostAPIResponse(data: data)
    }
}



