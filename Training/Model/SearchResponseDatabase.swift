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
        let userToken = UserDefaults.standard.string(forKey: "userToken")
        var headers = [String : String]()
        if userToken != nil {
            headers = [ "Authorization": "Bearer " + userToken! ]
        } else {
            headers = [ "Authorization": "No Auth" ]
        }
        super.init(request: APIMeetUpRequest(name: "API0006  Search ", path: "listPopularEvents", method: .get, header: headers, parameters: ["pageIndex" : pageIndex, "pageSize" : pageSize, "keyword" : keyword]))
    }
}

struct SearchsData : MeetUpResponse {
    var listSearch = [SearchResponseDatabase]()
    var status : Int!
    var errMessage : String!
    init(json: JSON) {
        status = json["status"].intValue
        if status == 0 {
            errMessage = json["error_message"].stringValue
        } else {
            let data = json["response"]["events"].array
            for item in data! {
                let events = SearchResponseDatabase(search: item)
                listSearch.append(events)
            }
        }
    }
}

