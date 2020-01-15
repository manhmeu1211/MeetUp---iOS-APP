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

class EventDetail: Object {
    
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
    @objc dynamic var nameGenre = ""
    @objc dynamic var vnLocation = ""
    @objc dynamic var vnContact = ""
    @objc dynamic var vnName = ""
    @objc dynamic var latValue = 0.0
    @objc dynamic var longValue = 0.0
    @objc dynamic var mystatus = 0
    @objc dynamic var locationEvent = ""
    
    convenience init(id: Int, photo :String , name: String, descriptionHtml : String, scheduleStartDate : String, scheduleEndDate : String, scheduleStartTime: String, scheduleEndTime : String, schedulePermanent : String, goingCount: Int, nameGenre : String, vnLocation : String, vnContact : String, vnName : String, locationEvent : String ) {
        self.init()
        self.id = id
        self.photo = photo
        self.name = name
        self.descriptionHtml = descriptionHtml
        self.scheduleStartDate = scheduleStartDate
        self.scheduleEndDate = scheduleEndDate
        self.scheduleStartTime = scheduleStartTime
        self.scheduleEndTime = scheduleEndTime
        self.schedulePermanent = schedulePermanent
        self.goingCount = goingCount
        self.vnName = vnName
        self.vnContact = vnContact
        self.vnLocation = vnLocation
        self.nameGenre = nameGenre
        self.locationEvent = locationEvent
    }
    
    
    convenience init(detail : JSON, detailVenue : JSON, detailGenre : JSON) {
        self.init()
        self.id = detail["id"].intValue
        self.photo = detail["photo"].stringValue
        self.name = detail["name"].stringValue
        self.descriptionHtml = detail["description_html"].stringValue
        self.scheduleStartDate = detail["schedule_start_date"].stringValue
        self.scheduleEndDate = detail["schedule_end_date"].stringValue
        self.scheduleStartTime = detail["schedule_start_time"].stringValue
        self.scheduleEndTime = detail["schedule_end_time"].stringValue
        self.schedulePermanent = detail["schedule_permanent"].stringValue
        self.goingCount = detail["going_count"].intValue
        self.vnName = detailVenue["name"].stringValue
        self.vnContact = detailVenue["contact_phone"].stringValue
        self.vnLocation = detailVenue["contact_address"].stringValue
        self.nameGenre = detailGenre["name"].stringValue
        self.latValue = detailVenue["geo_lat"].doubleValue
        self.longValue = detailVenue["geo_long"].doubleValue
        self.mystatus = detail["my_status"].intValue
        self.locationEvent = detailVenue["name"].stringValue
    }
}


class EventsDetailAPI: APIMeetUpService<EventDetailData> {
    init(eventID: Int) {
        super.init(request: APIMeetUpRequest(name: "API0009  Get events going ", path: "getDetailEvent", method: .get, header: APIMeetUpRequest.header, parameters: ["event_id" : eventID]))
    }
}

struct EventDetailData : MeetUpResponse {
    var eventDetail = EventDetail()
    var status : Int!
    var errMessage : String!
    init(json: JSON) {
        status = json["status"].intValue
        if status == 0 {
            errMessage = json["error_message"].stringValue
        } else {
            let data = json["response"]["events"]
            let detailVenue = data["venue"]
            let detailGenre = data["category"]
            eventDetail = EventDetail(detail: data, detailVenue: detailVenue, detailGenre: detailGenre)
            print(detailVenue)
        }
    }
}








