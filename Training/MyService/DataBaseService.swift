//
//  NewsItemViewModel.swift
//  Training
//
//  Created by ManhLD on 12/10/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift


class getDataService {
    
    let realm = try! Realm()
    let baseURL = "http://meetup.rikkei.org/api/v0/"
    
    static let getInstance: getDataService = {
        let instance = getDataService()
        return instance
    }()
    

    private func deleteObject(object : Object.Type) {
           let list = realm.objects(object).toArray(ofType: object)
           try! realm.write {
               realm.delete(list)
           }
    }
    
    private func addListObject(object : Object) {
        try! realm.write {
            realm.add(object)
        }
    }
    
    func getListNews(pageIndex : Int, pageSize : Int, shoudLoadmore: Bool, completionHandler: @escaping ([NewsDataResponse], Int) -> ()) {
        if shoudLoadmore == false {
            self.deleteObject(object: NewsDataResponse.self)
            NewsListAPI(pageIndex: pageIndex, pageSize: pageSize).excute(completionHandler: { [weak self] (response) in
               let data = response!.listNews
                _ = data.forEach({ (news) in
                    self!.addListObject(object: news)
                })
                let dataLoaded = RealmDataBaseQuery.getInstance.getObjects(type: NewsDataResponse.self)?.toArray(ofType: NewsDataResponse.self)
                completionHandler(dataLoaded!, 1)
            }) { (err) in
                completionHandler([], 0)
                print(err!)
            }
        } else {
            NewsListAPI(pageIndex: pageIndex, pageSize: pageSize).excute(completionHandler: { (response) in
               let data = response!.listNews
                _ = data.forEach({ (news) in
                    self.addListObject(object: news)
                })
                let dataLoaded = RealmDataBaseQuery.getInstance.getObjects(type: NewsDataResponse.self)?.toArray(ofType: NewsDataResponse.self)
                completionHandler(dataLoaded!, 1)
            }) { (err) in
                print(err!)
                completionHandler([], 0)
            }

        }
    }
    
    func getListPopular(pageIndex: Int, pageSize: Int, headers: HTTPHeaders, isLoadmore : Bool, completionHandler : @escaping ([PopularsResDatabase], Int) -> ()) {
        if isLoadmore == false {
            self.deleteObject(object: PopularsResDatabase.self)
            EventsListAPI(pageIndex: pageIndex, pageSize: pageSize).excute(completionHandler: { [weak self] (response) in
               let data = response!.listNews
                _ = data.forEach({ (events) in
                    self!.addListObject(object: events)
                })
                let dataLoaded = RealmDataBaseQuery.getInstance.getObjects(type: PopularsResDatabase.self)?.toArray(ofType: PopularsResDatabase.self)
                completionHandler(dataLoaded!, 1)
            }) { (err) in
                completionHandler([], 0)
                print(err!)
            }
        } else {
            EventsListAPI(pageIndex: pageIndex, pageSize: pageSize).excute(completionHandler: { [weak self] (response) in
               let data = response!.listNews
                _ = data.forEach({ (events) in
                    self!.addListObject(object: events)
                })
                let dataLoaded = RealmDataBaseQuery.getInstance.getObjects(type: PopularsResDatabase.self)?.toArray(ofType: PopularsResDatabase.self)
                completionHandler(dataLoaded!, 1)
            }) { (err) in
                print(err!)
                completionHandler([], 0)
            }

        }
    }
    
    
    func getListCategories(completionHandler : @escaping ([CategoriesResDatabase], Int) -> ()) {
        CategoriesListAPI().excute(completionHandler: { [weak self] (response) in
            let data = response!.listCategories
            self!.deleteObject(object: CategoriesResDatabase.self)
            _ = data.forEach({ (cate) in
                self!.addListObject(object: cate)
            })
            let dataLoaded = RealmDataBaseQuery.getInstance.getObjects(type: CategoriesResDatabase.self)?.toArray(ofType: CategoriesResDatabase.self)
            completionHandler(dataLoaded!, 1)
        })
            { (err) in
            completionHandler([], 0)
        }
    }
    
    
    func getListNearEvent(radius: Double, longitue : Double, latitude : Double, completionHandler : @escaping ([EventsNearResponse], JSON?, Int) ->()) {
        ArtWorkListAPI(radius: radius, longitue: longitue, latitude: latitude).excute(completionHandler: { [weak self] (response) in
            self!.deleteObject(object: EventsNearResponse.self)
            if response!.statusCode == 0 {
                print(response!.anotion ?? "Lỗi hệ thống")
                completionHandler([], nil, 0)
            } else {
                let data = response!.listEventsNear
                _ = data.forEach({ (eventsNear) in
                    self!.addListObject(object: eventsNear)
                })
                let anotion = response!.anotion
                let dataLoaded = RealmDataBaseQuery.getInstance.getObjects(type: EventsNearResponse.self)?.toArray(ofType: EventsNearResponse.self)
                completionHandler(dataLoaded!, anotion, 1)
            }
        }) { (err) in
            completionHandler([], nil ,0)
        }
    }
    
    
    func search(pageIndex: Int, pageSize : Int, keyword : String, isLoadMore : Bool, completionHandler: @escaping ([SearchResponseDatabase], Int) -> ()) {
        SearchListAPI(pageIndex: pageIndex, pageSize: pageSize, keyword: keyword).excute(completionHandler: { [weak self] (response) in
            let status = response!.status
            if status == 0 {
                print(response?.errMessage ?? "Lỗi hệ thống")
                completionHandler([], 0)
            } else {
                let data = response!.listSearch
                if isLoadMore == false {
                    self!.deleteObject(object: SearchResponseDatabase.self)
                    for item in data {
                        self!.addListObject(object: item)
                    }
                } else {
                    for item in data {
                        self!.addListObject(object: item)
                    }
                }
                let searchResult = RealmDataBaseQuery.getInstance.getObjects(type: SearchResponseDatabase.self)?.toArray(ofType: SearchResponseDatabase.self)
                completionHandler(searchResult!, 1)
            }
        }) { (err) in
            print(err!)
            completionHandler([], 0)
        }
    }
    
    
    func getListEventsByCategories(cateID: Int, pageIndex : Int, isLoadMore : Bool, completionHandler : @escaping ([EventsByCategoriesDatabase], Int) ->()) {
        EventsByCategoriesListAPI(pageIndex: pageIndex, pageSize: 10, categoriesID: cateID).excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                print(response?.errMessage ?? "Lỗi hệ thống")
                completionHandler([], 0)
            } else {
                let data = response!.listEventsByCate
                if isLoadMore == false {
                    self!.deleteObject(object: EventsByCategoriesDatabase.self)
                    _ = data.forEach({ (event) in
                        self!.addListObject(object: event)
                    })
                } else {
                    _ = data.forEach({ (event) in
                        self!.addListObject(object: event)
                    })
                }
                let eventByCate = RealmDataBaseQuery.getInstance.getObjects(type: EventsByCategoriesDatabase.self)?.toArray(ofType: EventsByCategoriesDatabase.self)
                completionHandler(eventByCate!, 1)
            }
        }) { (err) in
            print(err!)
            completionHandler([], 0)
        }
    }
    
   func getMyEventGoing(status : Int, completionHandler : @escaping([MyPageGoingResDatabase], Int) -> ()) {
        MyPageGoingsListAPI(status: status).excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                print(response?.errMessage ?? "Lỗi hệ thống")
                completionHandler([], 1)
            } else {
                self!.deleteObject(object: MyPageGoingResDatabase.self)
                let data = response!.listEventsGoings
                _ = data.forEach({ (event) in
                    self!.addListObject(object: event)
                })
                let eventsGoing = RealmDataBaseQuery.getInstance.getObjects(type: MyPageGoingResDatabase.self)?.toArray(ofType: MyPageGoingResDatabase.self)
                completionHandler(eventsGoing!, 2)
            }
        }) { (err) in
            print(err!)
            completionHandler([], 0)
        }
    }
    

   func getMyEventWent(status : Int, completionHandler : @escaping([MyPageWentResDatabase], Int) -> ()) {
        MyPageWentListAPI(status: status).excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                print(response?.errMessage ?? "Lỗi hệ thống")
                completionHandler([], 0)
            } else {
                let data = response!.listEventsWent
                self!.deleteObject(object: MyPageWentResDatabase.self)
                _ = data.forEach({ (event) in
                    self!.addListObject(object: event)
                })
                let eventsWent = RealmDataBaseQuery.getInstance.getObjects(type: MyPageWentResDatabase.self)?.toArray(ofType: MyPageWentResDatabase.self)
                completionHandler(eventsWent!, 1)
            }
        }) { (err) in
            print(err!)
            completionHandler([], 0)
        }
    }
    
    func getEventDetail(eventID : Int, completionHandler : @escaping(EventDetail, Int) -> () ) {
        EventsDetailAPI(eventID: eventID).excute(completionHandler: { (response) in
            if response!.status == 0 {
                completionHandler(EventDetail(id: 0, photo: "", name: "Failed to load", descriptionHtml: "", scheduleStartDate: "", scheduleEndDate: "", scheduleStartTime: "", scheduleEndTime: "", schedulePermanent: "", goingCount: 0, nameGenre: "", vnLocation: "", vnContact: "", vnName: ""), 0)
            } else {
                let data = response?.eventDetail
                completionHandler(data!, 1)
            }
           
        }) { (err) in
                completionHandler(EventDetail(id: 0, photo: "", name: "Failed to load", descriptionHtml: "", scheduleStartDate: "", scheduleEndDate: "", scheduleStartTime: "", scheduleEndTime: "", schedulePermanent: "", goingCount: 0, nameGenre: "", vnLocation: "", vnContact: "", vnName: ""), 0)
            print(err!)
        }
    }
    
    func register(params: [String : String], completionHandler : @escaping (JSON?, Int) -> ()) {
        printInfomationRequest(name: "API00013  Register", url: baseURL + "register", method: .post, header: nil, parameters: params, keyValue: "response")
        Alamofire.request(baseURL + "register", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(let value):
            let response = JSON(value)
            let data = response["response"]
            completionHandler(data, 1)
            case .failure( _):
            completionHandler(nil, 0)
            }
        }
    }
    
    func login(params : [String : String], completionHandler : @escaping (JSON?, Int) -> ()) {
        printInfomationRequest(name: "API00012  Login", url: baseURL + "login", method: .post, header: nil, parameters: params, keyValue: "response")
        Alamofire.request(baseURL + "login", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(let value):
            let response = JSON(value)
            let status = response["status"]
            var data = response["response"]
            if status == 0 {
                data = response["error_message"]
                completionHandler(data, 1)
            } else {
                data = response["response"]
                completionHandler(data, 2)
            }
            case .failure( _):
            completionHandler(nil, 0)
            }
        }
    }
    
    func resetPassword(params : [String : String], completionHandler : @escaping (JSON?, Int) -> ()) {
           printInfomationRequest(name: "API00011  Reset password", url: baseURL + "resetPassword", method: .post, header: nil, parameters: params, keyValue: "response")
        Alamofire.request(baseURL + "resetPassword", method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseJSON { (response) in
             switch response.result {
                case .success(let value):
                let response = JSON(value)
                let status = response["status"]
                var data = response["response"]
                if status == 0 {
                    data = response["error_message"]
                    completionHandler(data, 1)
                } else {
                    data = response["response"]
                    completionHandler(data, 2)
                }
                case .failure( _):
                completionHandler(nil, 0)
            }
        }
    }
    
    func doUpdateEvent(params : [String : Any], headers : HTTPHeaders, completionHandler : @escaping(JSON?, Int) -> ()) {
        printInfomationRequest(name: "API00010  Do Update Event ", url: baseURL + "doUpdateEvent", method: .post, header: headers, parameters: params, keyValue: "response")
        Alamofire.request(baseURL + "doUpdateEvent", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { (response) in
              switch response.result {
                case .success(let value):
                let response = JSON(value)
                let status = response["status"]
                if status == 0 {
                    let data = response["error_message"]
                    completionHandler(data, 1)
                } else {
                    completionHandler(status, 2)
                }
                case .failure( _):
                completionHandler(nil, 0)
            }
        }
    }
    
    
    func printInfomationRequest(name: String, url : String, method : HTTPMethod, header : [String : Any]? = nil, parameters : [String : Any]? = nil, keyValue : String) {
        print("Request name : \(name)")
        print("Request url : \(url)")
        print("Request method : \(method)")
        print("Request header : \(String(describing: header))")
        print("Request params :", parameters!)
        print("Request keyValue : \(keyValue)")
    }
}
