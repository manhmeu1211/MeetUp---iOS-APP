import Foundation
import SwiftyJSON



class UpdateEventStatusAPI: APIMeetUpService<UpDateEventsStatusResponse> {
    init(status: Int, eventID : Int) {
        let userToken = UserDefaults.standard.string(forKey: "userToken")
        var headers = [String : String]()
        if userToken != nil {
            headers = [ "Authorization": "Bearer " + userToken! ]
        } else {
            headers = [ "Authorization": "No Auth" ]
        }
        super.init(request: APIMeetUpRequest(name: "API00011  Update status event ", path: "doUpdateEvent", method: .post, header: headers ,parameters: ["status": status, "event_id": eventID]))
    }
}

struct UpDateEventsStatusResponse : MeetUpResponse {
    var updateModel = PostAPIResponse()
    init(json: JSON) {
        let data = json
        updateModel = PostAPIResponse(data: data)
    }
}


