//
//  UpdateModel.swift
//  Training
//
//  Created by ManhLD on 12/31/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import SwiftyJSON


struct UpDateModel {
    var status : Int
    var errorCode : Int
    var errorMessage : String
}

class UpdateEventStatusAPI: APIMeetUpService<UpDateEventsStatus> {
    init(status: Int, eventID : Int) {
        super.init(request: APIMeetUpRequest(name: "API00010  Update status event ", path: "doUpdateEvent", method: .post, parameters: ["status": 2, "event_id": eventID]))
    }
}

struct UpDateEventsStatus : MeetUpResponse {
    var updateModel = UpDateModel(status: 0, errorCode: 0, errorMessage: "Nothing")
    init(json: JSON) {
        let status = json["status"].intValue
        let errorCode = json["error_code"].intValue
        let errorMessage = json["error_message"].stringValue
        updateModel = UpDateModel(status: status, errorCode: errorCode, errorMessage: errorMessage)
    }
    
}


