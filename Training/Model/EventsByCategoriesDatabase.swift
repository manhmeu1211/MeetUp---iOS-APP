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
    
    @objc dynamic var id: Int  = 0
    @objc dynamic var photo: String  = ""
    @objc dynamic var name: String  = ""
    @objc dynamic var descriptionHtml: String  = ""
    @objc dynamic var scheduleStartDate: String  = ""
    @objc dynamic var scheduleEndDate: String  = ""
    @objc dynamic var scheduleStartTime: String  = ""
    @objc dynamic var scheduleEndTime: String  = ""
    @objc dynamic var schedulePermanent: String  = ""
    @objc dynamic var goingCount: Int  = 0
    
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
    var status : Int = 0
    var errMessage : String?
    init(json: JSON) {
        status = json["status"].intValue
        if status == 0 {
            errMessage = json["error_message"].stringValue
        } else {
            let data = json["response"]["events"].array
            if data!.isEmpty {
                errMessage = "Empty"
            } else {
                listEventsByCate = data!.map({ (value) -> EventsByCategoriesDatabase in
                    return EventsByCategoriesDatabase(event: value)
                })
            }
        }
    }
}

