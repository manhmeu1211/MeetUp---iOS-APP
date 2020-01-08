//
//  NearViewController.swift
//  Training
//
//  Created by ManhLD on 12/13/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import RealmSwift

class NearViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionVIew: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    private var alert = UIAlertController()
    
    // MARK: - Varribles
    private let realm = try! Realm()
    private var events = [EventsNearResponse]()
    private var anotion = [Artwork]()
    private let locationManager = CLLocationManager()
    private let regionRadius: CLLocationDistance = 1000
    private var centralLocationCoordinate : CLLocationCoordinate2D!
    private var currentLocation: CLLocation!
    private var initLong, initLat : Double?
    private var eventLong = [Double]()
    private var eventLat = [Double]()
    private var indexRow : Int!
    private var isConnected : Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.handleLoading(isLoading: true)
        setUpCollectionView()
        checkConnection()
        getLocation()
        getListEventV2()
        updateObject()
    }
    
    
    // MARK: - Setup Location - MapView
   
    
    
    private func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() ==  .authorizedAlways) {
                currentLocation = locationManager.location
                initLong = currentLocation.coordinate.longitude
                initLat = currentLocation.coordinate.latitude
                centerMapOnLocation(location: CLLocation(latitude: initLat!, longitude: initLong!))
            } else {
                initLong = 105.874993
                initLat =  21.044895
            }
        addArtwork()
    }
    
    private func addArtwork() {
          map.mapType = MKMapType.standard
        let artwork = Artwork(title: "anootation.title".localized,
                              locationName: "My Location".localized,
                              discipline: "My Location".localized,
                 coordinate: CLLocationCoordinate2D(latitude: initLat!, longitude: initLong!))
          map.addAnnotation(artwork)
    }
    
    private func checkConnection() {
           NotificationCenter.default.addObserver(self, selector: #selector(NewsViewController.networkStatusChanged(_:)), name: Notification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
          Reach().monitorReachabilityChanges()
       }
       
       @objc func networkStatusChanged(_ notification: Notification) {
           if let userInfo = notification.userInfo {
               let statusConnect = userInfo["Status"] as! String
               print(statusConnect)
           }
           let status = Reach().connectionStatus()
               switch status {
                   case .unknown, .offline:
                       isConnected = false
                   case .online(.wwan):
                       isConnected = true
                       loading.handleLoading(isLoading: true)
                       getListEventV2()
                   case .online(.wiFi):
                       isConnected = true
                       loading.handleLoading(isLoading: true)
                       getListEventV2()
               }
        }
    
    // MARK: - Setup views
    
    private func setUpCollectionView() {
        map.delegate = self
        collectionVIew.dataSource = self
        collectionVIew.delegate = self
        collectionVIew.showsHorizontalScrollIndicator = false
        collectionVIew.isPagingEnabled = true
        collectionVIew.register(UINib(nibName: "EventsCell", bundle: nil), forCellWithReuseIdentifier: "EventsCell")
    }
    

    private func getListEventV2() {
        let token = UserDefaults.standard.string(forKey: "userToken")
        if token != nil {
            getListEvent()
        } else {
            showAlert(message: "haveToLogin.label.text".localized, titleBtn: "alert.titleBtn.login".localized) {
                self.handleLoginView()
            }
        }
    }
    
    
    @objc func handleLoginView() {
        let tabbarController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! TabbarViewController
        tabbarController.isLoginVC = true
        UIApplication.shared.windows.first?.rootViewController = tabbarController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
  // MARK: - getData
    
    private func updateObject() {
        let list = RealmDataBaseQuery.getInstance.getObjects(type: EventsNearResponse.self)!.sorted(byKeyPath: "goingCount", ascending: false).toArray(ofType: EventsNearResponse.self)
        if list.isEmpty {
            events.append(EventsNearResponse(id: 0, photo: "", name: "noEvent.label.text".localized, descriptionHtml: "", scheduleStartDate: "", scheduleEndDate: "", scheduleStartTime: "", scheduleEndTime: "", schedulePermanent: "", goingCount: 0))
        } else {
            events = list
        }
    }
      
    private func getListEvent() {
        getDataService.getInstance.getListNearEvent(radius: 10, longitue: self.initLong!, latitude: self.initLat!) { [weak self] (eventsNear, anotionLC ,errcode) in
            if errcode == 1 {
                self!.events.removeAll()
                _ = anotionLC?.array?.forEach({ (anotion) in
                    let anotionArt = Artwork(anotion: anotion, coordinate: CLLocationCoordinate2D(latitude: anotion["venue"]["geo_lat"].doubleValue, longitude: anotion["venue"]["geo_long"].doubleValue))
                    self!.map.addAnnotation(anotionArt)
                self!.eventLong.append(anotion["venue"]["geo_long"].doubleValue)
                    self!.eventLat.append(anotion["venue"]["geo_lat"].doubleValue)
                })
                self!.events = eventsNear
                self!.updateObject()
                self!.collectionVIew.reloadData()
                self!.loading.handleLoading(isLoading: false)
            } else {
                self!.updateObject()
                self!.collectionVIew.reloadData()
                self!.loading.handleLoading(isLoading: false)
            }
        }
    }
    
    private func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }



    private func getRadius(centralLocation: CLLocation) -> Double {
        let topCentralLat:Double = centralLocation.coordinate.latitude -  map.region.span.latitudeDelta/2
        let topCentralLocation = CLLocation(latitude: topCentralLat, longitude: centralLocation.coordinate.longitude)
        let radius = centralLocation.distance(from: topCentralLocation)
        return radius / 1000.0
    }
}


// MARK: - Extension collection view

extension NearViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventsCell", for: indexPath) as! EventsCell
        let queue = DispatchQueue(label: "loadImageNear")
        queue.async {
            DispatchQueue.main.async {
                cell.imgEvent.image = UIImage(data: self.events[indexPath.row].photo)
            }
        }
        cell.eventName.text = events[indexPath.row].name
        cell.eventDes.text = events[indexPath.row].descriptionHtml
        cell.eventCount.text = "\(events[indexPath.row].scheduleStartDate) - \(events[indexPath.row].goingCount) " + "peopleGoing.text".localized
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionVIew.frame.width - 10, height: self.collectionVIew.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userToken = UserDefaults.standard.string(forKey: "userToken")
        if userToken == nil {
            loading.handleLoading(isLoading: false)
        } else {
            if eventLat.isEmpty || eventLong.isEmpty {
                print("No event near")
            } else {
                if isConnected {
                centerMapOnLocation(location: CLLocation(latitude: eventLat[indexPath.row], longitude: eventLong[indexPath.row]))
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isConnected {
            for cell in collectionVIew.visibleCells {
                let indexPath = collectionVIew.indexPath(for: cell)
                centerMapOnLocation(location: CLLocation(latitude: eventLat[indexPath!.row], longitude: eventLong[indexPath!.row]))
            }
        }
    }
}


extension NearViewController : MKMapViewDelegate {
    private func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if isConnected {
            let centralLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude:  mapView.centerCoordinate.longitude)
                self.centralLocationCoordinate = mapView.centerCoordinate
               print("Radius - \(self.getRadius(centralLocation: centralLocation))")
        }
    }
    
    internal func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isConnected {
            let latValue = view.annotation?.coordinate.latitude
            let longValue = view.annotation?.coordinate.longitude
            centerMapOnLocation(location: CLLocation(latitude: latValue!, longitude: longValue!))
        }
    }
}
