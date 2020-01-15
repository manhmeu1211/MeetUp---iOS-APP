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

class EventsByCategoriesDatabase: Object {
    
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
    
    convenience init(event : JSON) {
        self.init()
        self.id = event["id"].intValue
        self.photo = event["photo"].stringValue
        self.name = event["name"].stringValue
        self.descriptionHtml = event["description_html"].stringValue
        self.scheduleStartDate = event["schedule_start_date"].stringValue
        self.scheduleEndDate = event["schedule_end_date"].stringValue
        self.scheduleStartTime = event["schedule_start_time"].stringValue
        self.scheduleEndTime = event["schedule_end_time"].stringValue
        self.schedulePermanent = event["schedule_permanent"].stringValue
        self.goingCount = event["going_count"].intValue
    }
}



class EventsByCategoriesListAPI: APIMeetUpService<EventsByCategoriesData> {
    init(pageIndex: Int, pageSize : Int, categoriesID: Int) {
        super.init(request: APIMeetUpRequest(name: "API0005  Get events by categoris ", path: "listEventsByCategory", method: .get, header: APIMeetUpRequest.header, parameters: ["pageIndex" : pageIndex, "pageSize" : pageSize, "category_id" : categoriesID]))
    }
}

struct EventsByCategoriesData : MeetUpResponse {
    var listEventsByCate = [EventsByCategoriesDatabase]()
    var status : Int!
    var errMessage : String!
    init(json: JSON) {
        status = json["status"].intValue
        if status == 0 {
            errMessage = json["error_message"].stringValue
        } else {
            let data = json["response"]["events"].array
            if data!.isEmpty {
                errMessage = "Empty"
            } else {
                for item in data! {
                    let events = EventsByCategoriesDatabase(event: item)
                    listEventsByCate.append(events)
                }
            }
        }
    }
}

