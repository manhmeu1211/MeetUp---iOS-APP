//
//  EventsNearResponse.swift
//  Training
//
//  Created by ManhLD on 12/17/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON


class EventsNearResponse: Object {
    
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
    
   convenience init(id: Int, photo :String , name: String, descriptionHtml : String, scheduleStartDate : String, scheduleEndDate : String, scheduleStartTime: String, scheduleEndTime : String, schedulePermanent : String, goingCount: Int ) {
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
    }
    
    convenience init(events : JSON) {
        self.init()
        self.id = events["id"].intValue
        self.photo = events["photo"].stringValue
        self.name = events["name"].stringValue
        self.descriptionHtml = events["description_html"].stringValue
        self.scheduleStartDate = events["schedule_start_date"].stringValue
        self.scheduleEndDate = events["schedule_end_date"].stringValue
        self.scheduleStartTime = events["schedule_start_time"].stringValue
        self.scheduleEndTime = events["schedule_end_time"].stringValue
        self.schedulePermanent = events["schedule_permanent"].stringValue
        self.goingCount = events["going_count"].intValue
    }
}
