//
//  PopularsResDatabase.swift
//  Training
//
//  Created by ManhLD on 12/12/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//


import Foundation
import RealmSwift
import SwiftyJSON

class PopularsResDatabase: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var photo = ""
    @objc dynamic var name = ""
    @objc dynamic var descriptionHtml = ""
    @objc dynamic var scheduleStartDate = ""
    @objc dynamic var scheduleEndDate = ""
    @objc dynamic var scheduleStartTime = ""
    @objc dynamic var scheduleEndTime = ""
    @objc dynamic var schedulePermanent = ""
    @objc dynamic var goingCount = 0
    @objc dynamic var myStatus = 0

    
    convenience init(populars : JSON) {
        self.init()
        self.id = populars["id"].intValue
        self.photo = populars["photo"].stringValue
        self.name = populars["name"].stringValue
        self.descriptionHtml = populars["description_html"].stringValue
        self.scheduleStartDate = populars["schedule_start_date"].stringValue
        self.scheduleEndDate = populars["schedule_end_date"].stringValue
        self.scheduleStartTime = populars["schedule_start_time"].stringValue
        self.scheduleEndTime = populars["schedule_end_time"].stringValue
        self.schedulePermanent = populars["schedule_permanent"].stringValue
        self.goingCount = populars["going_count"].intValue
        self.myStatus = populars["my_status"].intValue
    }
}


class EventsListAPI: APIMeetUpService<PopularsData> {
    init(pageIndex: Int, pageSize : Int) {
        super.init(request: APIMeetUpRequest(name: "API0002  Get events ", path: "listPopularEvents", method: .get, header: APIMeetUpRequest.header, parameters: ["pageIndex" : pageIndex, "pageSize" : pageSize]))
    }
}

struct PopularsData : MeetUpResponse {
    var listPopulars = [PopularsResDatabase]()
    var errMessage : String!
    var status : Int!
    init(json: JSON) {
        let data = json["response"]["events"].array
        status = json["status"].intValue
        if status == 1 {
            for item in data! {
                let populars = PopularsResDatabase(populars: item)
                listPopulars.append(populars)
            }
        } else {
            errMessage = json["error_message"].stringValue
        }
    }
}
