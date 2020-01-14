//
//  CategoriesDatabase.swift
//  Training
//
//  Created by ManhLD on 12/12/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON


class CategoriesResDatabase: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var slug = ""
    @objc dynamic var parentId = 0
    @objc dynamic var icon = ""
  
 
    convenience init(cate: JSON, icon : String) {
        self.init()
        self.id = cate["id"].intValue
        self.name = cate["name"].stringValue
        self.slug = cate["slug"].stringValue
        self.parentId = cate["parent_id"].intValue
        self.icon = icon
    }
}


class CategoriesListAPI: APIMeetUpService<CategoriesData> {
    init() {
        super.init(request: APIMeetUpRequest(name: "API0003  Get categories ", path: "listCategories", method: .get))
    }
}

struct CategoriesData : MeetUpResponse {
    var listCategories = [CategoriesResDatabase]()
    var status : Int!
    var errMessage : String!
    private let listIcon = ["fan", "bag", "car", "grow", "dance", "mortarboard", "woman"]
    init(json: JSON) {
        status = json["status"].intValue
        if status == 0 {
            errMessage = json["error_mesage"].stringValue
        } else {
            let data = json["response"]["categories"].array
            let icon = listIcon[0]
            for item in data! {
                let categories = CategoriesResDatabase(cate : item, icon: icon)
                listCategories.append(categories)
            }
        }
    }
}


