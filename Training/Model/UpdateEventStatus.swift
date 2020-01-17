import Foundation
import SwiftyJSON



class UpdateEventStatusAPI: APIMeetUpService<UpDateEventsStatusResponse> {
    init(status: Int, eventID : Int) {
        super.init(request: APIMeetUpRequest(name: "API00011  Update status event ",
                                             path: "doUpdateEvent",
                                             method: .post,
                                             header: APIMeetUpRequest.header ,
                                             parameters: ["status": status, "event_id": eventID]))
    }
}

struct UpDateEventsStatusResponse : MeetUpResponse {
    var updateModel = PostAPIResponse()
    init(json: JSON) {
        let data = json
        updateModel = PostAPIResponse(data: data)
    }
}


