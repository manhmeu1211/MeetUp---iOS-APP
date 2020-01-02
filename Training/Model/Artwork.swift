//
//  ArtWork.swift
//  Training
//
//  Created by ManhLD on 12/13/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import SwiftyJSON

import MapKit

class Artwork: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D

    init(anotion : JSON, coordinate: CLLocationCoordinate2D) {
        self.title = anotion["venue"]["name"].stringValue
        self.locationName = anotion["venue"]["name"].stringValue
        self.discipline = anotion["venue"]["description"].stringValue
        self.coordinate = coordinate
        super.init()
  }
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
       self.title = title
       self.locationName = locationName
       self.discipline = discipline
       self.coordinate = coordinate
       super.init()
    }
  
  var subtitle: String? {
    return locationName
  }
    
}



class ArtWorkListAPI: APIMeetUpService<ArtWorksData> {
    init(radius: Double, longitue : Double, latitude : Double) {
        let userToken = UserDefaults.standard.string(forKey: "userToken")
        var headers = [String : String]()
        if userToken != nil {
            headers = [ "Authorization": "Bearer " + userToken! ]
        } else {
            headers = [ "Authorization": "No Auth" ]
        }
        super.init(request: APIMeetUpRequest(name: "API0004  Get Events Near ", path: "listNearlyEvents", method: .get, header: headers, parameters: ["radius" : radius, "longitue" : longitue, "latitude" : latitude ]))
    }
}

struct ArtWorksData : MeetUpResponse {
    var listEventsNear = [EventsNearResponse]()
    var anotion : JSON!
    var statusCode : Int!
    init(json: JSON) {
        let status = json["status"]
        statusCode = status.intValue
        if statusCode == 0 {
            anotion = status
        } else {
            anotion = json["response"]["events"]
            let events = json["response"]["events"].array
            for item in events! {
                let eventsNear = EventsNearResponse(events : item)
                listEventsNear.append(eventsNear)
            }
        }
    }
}



