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
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var slug: String = ""
    @objc dynamic var parentId: Int = 0
    @objc dynamic var icon: String = ""
  
 
    convenience init(cate: JSON) {
        self.init()
        self.id = cate["id"].intValue
        self.name = cate["name"].stringValue
        self.slug = cate["slug"].stringValue
        self.parentId = cate["parent_id"].intValue
        
    }
}


class CategoriesListAPI: APIMeetUpService<CategoriesData> {
    init() {
        super.init(request: APIMeetUpRequest(name: "API0003  Get categories ", path: "listCategories", method: .get))
    }
}

struct CategoriesData : MeetUpResponse {
    var listCategories = [CategoriesResDatabase]()
    var status : Int = 0
    var errMessage : String?
    init(json: JSON) {
        status = json["status"].intValue
        if status == 0 {
            errMessage = json["error_mesage"].stringValue 
        } else {
            let data = json["response"]["categories"].array
            listCategories = data!.map({ (value) -> CategoriesResDatabase in
                return CategoriesResDatabase(cate: value)
            })
        }
    }
}


