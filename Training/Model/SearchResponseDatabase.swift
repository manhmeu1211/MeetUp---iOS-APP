//
//  SearchResponseDatabase.swift
//  Training
//
//  Created by ManhLD on 12/17/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class SearchResponseDatabase: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var photo: String = ""
    @objc dynamic var name: String  = ""
    @objc dynamic var descriptionHtml: String  = ""
    @objc dynamic var scheduleStartDate: String  = ""
    @objc dynamic var scheduleEndDate: String  = ""
    @objc dynamic var scheduleStartTime: String  = ""
    @objc dynamic var scheduleEndTime: String  = ""
    @objc dynamic var schedulePermanent: String  = ""
    @objc dynamic var goingCount: Int = 0
    
    convenience init(search : JSON) {
        self.init()
        self.id = search["id"].intValue
        self.photo = search["photo"].stringValue
        self.name = search["name"].stringValue
        self.descriptionHtml = search["description_html"].stringValue
        self.scheduleStartDate = search["schedule_start_date"].stringValue
        self.scheduleEndDate = search["schedule_end_date"].stringValue
        self.scheduleStartTime = search["schedule_start_time"].stringValue
        self.scheduleEndTime = search["schedule_end_time"].stringValue
        self.schedulePermanent = search["schedule_permanent"].stringValue
        self.goingCount = search["going_count"].intValue
    }
}


class SearchListAPI: APIMeetUpService<SearchsData> {
    init(pageIndex: Int, pageSize : Int, keyword : String) {
        super.init(request: APIMeetUpRequest(name: "API0006  Search ", path: "listPopularEvents", method: .get, header: APIMeetUpRequest.header, parameters: ["pageIndex" : pageIndex, "pageSize" : pageSize, "keyword" : keyword]))
    }
}

struct SearchsData : MeetUpResponse {
    var listSearch = [SearchResponseDatabase]()
    var status : Int = 0
    var errMessage : String?
    init(json: JSON) {
        status = json["status"].intValue
        if status == 0 {
            errMessage = json["error_message"].stringValue ?? ""
        } else {
            let data = json["response"]["events"].array
            data?.forEach({ (value) in
                listSearch.append(SearchResponseDatabase(search: value))
            })
        }
    }
}

