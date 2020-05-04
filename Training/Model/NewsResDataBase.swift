//
//  NewsResDataBase.swift
//  Training
//
//  Created by ManhLD on 12/12/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//
//


import Foundation
import RealmSwift
import SwiftyJSON

class NewsDataResponse: Object {
    @objc dynamic var id = 0
    @objc dynamic var feed = ""
    @objc dynamic var title = ""
    @objc dynamic var thumbImg = ""
    @objc dynamic var author = ""
    @objc dynamic var publishdate = ""
    @objc dynamic var url = ""
    
    let dateFormatter = Date()
    
    
    convenience init(news : JSON) {
        self.init()
        self.id = news["id"].intValue
        self.feed = news["feed"].stringValue
        self.title = news["title"].stringValue
        self.thumbImg = news["thumb_img"].stringValue
        self.author = news["author"].stringValue
        let date = self.dateFormatter.converStringToDate(formatter: .dateTimeFromServer, dateString: news["publish_date"].stringValue)
        let dateString = date?.convertDateToString(formatter: .dayAndDate, date: date!)
        self.publishdate = dateString!
        self.url = news["detail_url"].stringValue
    }
}

class NewsListAPI: APIMeetUpService<NewsData> {
    init(pageIndex: Int, pageSize : Int) {
        super.init(request: APIMeetUpRequest(name: "API0001  Get news ",
                                             path: "listNews",
                                             method: .get,
                                             parameters: ["pageIndex": pageIndex, "pageSize": pageSize]))
    }
}

struct NewsData : MeetUpResponse {
    var listNews = [NewsDataResponse]()
    var status : Int = 0
    var errMessage : String?
    init(json: JSON) {
        for (key, value) in json["response"] {
            print(key, value)
        }
        status = json["status"].intValue
        if status == 1 {
            let data = json["response"]["news"].array
            listNews = data!.map({ (value) -> NewsDataResponse in
                return NewsDataResponse(news: value)
            })
        } else {
            errMessage = json["error_message"].stringValue 
        }
    }
}
