//
//  ArtWork.swift
//  Training
//
//  Created by ManhLD on 12/13/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

import MapKit

class Artwork: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let myStatus : Int
    
    var markerTintColor: UIColor  {
        switch discipline {
            case "red":
                return .red
            case "Mural":
                return .cyan
            case "yellow":
                return .yellow
            case "Sculpture":
                return .purple
            default:
                return .green
        }
    }
    var imageName: String? {
        switch discipline {
            case "yellow":
                return "Flag"
            case "Sculpture":
                return "X"
            default:
                return "yellowMarker"
        }
    }

    init(anotion : JSON, coordinate: CLLocationCoordinate2D) {
        self.title = anotion["venue"]["name"].stringValue
        self.locationName = anotion["venue"]["name"].stringValue
        self.coordinate = coordinate
        self.myStatus = anotion["my_status"].intValue
        switch anotion["my_status"].intValue {
        case 1:
            self.discipline = "red"
        case 2:
            self.discipline = "yellow"
        default:
            self.discipline = "Sculpture"
        }
        super.init()
  }
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, myStatus : Int) {
        self.title = title
        self.locationName = locationName
        switch myStatus {
          case 1:
              self.discipline = "red"
          case 2:
              self.discipline = "yellow"
          default:
              self.discipline = "Sculpture"
          }
        self.coordinate = coordinate
        self.myStatus = myStatus
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
    var errMessage : String!
    init(json: JSON) {
        let status = json["status"]
        statusCode = status.intValue
        if statusCode == 0 {
            errMessage = json["error_message"].stringValue
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




