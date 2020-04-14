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
    
    @objc dynamic var id: Int = 0
    @objc dynamic var photo: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var descriptionHtml: String = ""
    @objc dynamic var scheduleStartDate: String = ""
    @objc dynamic var scheduleEndDate: String = ""
    @objc dynamic var scheduleStartTime: String = ""
    @objc dynamic var scheduleEndTime: String = ""
    @objc dynamic var schedulePermanent: String = ""
    @objc dynamic var goingCount: Int = 0
    @objc dynamic var myStatus: Int = 0
    let dateFormatter = Date()
    
    convenience init(populars : JSON) {
        self.init()
        self.id = populars["id"].intValue
        self.photo = populars["photo"].stringValue
        self.name = populars["name"].stringValue
        self.descriptionHtml = populars["description_html"].stringValue
        let date = self.dateFormatter.converStringToDate(formatter: .dateOnlyFromServer, dateString: populars["schedule_start_date"].stringValue)
        let dateString = date?.convertDateToString(formatter: .dayAndDate, date: date!)
        self.scheduleStartDate = dateString!
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
    var errMessage : String?
    var status : Int = 0
    init(json: JSON) {
        let data = json["response"]["events"].array
        status = json["status"].intValue
        if status == 1 {
            listPopulars = data!.map({ (value) -> PopularsResDatabase in
                return PopularsResDatabase(populars: value)
            })
        } else {
            errMessage = json["error_message"].stringValue ?? ""
        }
    }
}
