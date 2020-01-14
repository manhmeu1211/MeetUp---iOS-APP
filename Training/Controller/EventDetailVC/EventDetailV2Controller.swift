//
//  EventDetailV2Controller.swift
//  Training
//
//  Created by ManhLD on 1/14/20.
//  Copyright © 2020 ManhLD. All rights reserved.
//

import UIKit

class EventDetailV2Controller: UIViewController {
    
    @IBOutlet weak var imgDetail: UIImageView!
    @IBOutlet weak var detailDate: UILabel!
    @IBOutlet weak var nameDetail: UILabel!
    @IBOutlet weak var locationDetail: UILabel!
    @IBOutlet weak var desDetail: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var venueGenre: UILabel!
    @IBOutlet weak var venueLocation: UILabel!
    @IBOutlet weak var venueContact: UILabel!
    @IBOutlet weak var eventCollection: UICollectionView!
    @IBOutlet weak var btnGoing: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnWent: UIButton!
    @IBOutlet weak var backgroundStatusView: UIView!
    @IBOutlet weak var starStatus: UIImageView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var btnReadmore: UIButton!
    
    
    private var eventsNear = [EventsNearResponse]()
    private var eventDetail = EventDetail()
    var id : Int?
    private let userToken = UserDefaults.standard.string(forKey: "userToken")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        setUpView()
        getDetailEvent(eventID: id!)
        getListEventNear()
    }
    
    private func checkLoggedIn() -> Bool {
         if userToken == nil {
             return true
         }
         return false
     }
    
    
    private func setUpCollectionView() {
        eventCollection.delegate = self
        eventCollection.dataSource = self
        eventCollection.register(UINib(nibName: "EventsCell", bundle: nil), forCellWithReuseIdentifier: "EventsCell")
        eventCollection.showsHorizontalScrollIndicator = false
    }
    
    private func setUpView() {
        btnFollow.roundedButton()
        backgroundStatusView.setUpBGView()
        imgDetail.roundCorners()
        if checkLoggedIn() {
            btnGoing.backgroundColor = UIColor(rgb: 0xF6F6F6)
            btnWent.backgroundColor = UIColor(rgb: 0xF6F6F6)
            btnFollow.backgroundColor = UIColor(rgb: 0xF6F6F6)
        }
        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func swiped(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            id! += 1
            getDetailEvent(eventID: id!)
        } else if gesture.direction == .right {
            id! -= 1
            getDetailEvent(eventID: id!)
        }
    }
    
    
    private func setUpDataForView() {
        let url = URL(string: eventDetail.photo)
        imgDetail.sd_setImage(with: url, placeholderImage: UIImage(named: "noImage"), completed: nil)
        nameDetail.text = eventDetail.name
        detailDate.text = "\(eventDetail.scheduleStartDate) - \(eventDetail.goingCount) " + "peopleGoing.text".localized
        locationDetail.text = eventDetail.locationEvent
        desDetail.attributedText = eventDetail.descriptionHtml.htmlToAttributedString
        venueName.text = eventDetail.vnName
        venueGenre.text = eventDetail.nameGenre
        venueContact.text = eventDetail.vnContact
        venueLocation.text = eventDetail.vnLocation
        if eventDetail.mystatus == 1 {
            btnGoing.backgroundColor = UIColor.red
            starStatus.image = UIImage(named: "icon_starRed")
            status.text = "join.label.text.canParticipate".localized
            status.textColor = UIColor(rgb: 0xC63636)
            backgroundStatusView.backgroundColor = UIColor(rgb: 0xF9EBEB)
        } else if eventDetail.mystatus == 2 {
            btnWent.backgroundColor = UIColor.systemOrange
            starStatus.image =  UIImage(named: "icon_starGreen")
            status.text = "join.label.text.joined".localized
            status.textColor = UIColor(rgb: 0x00C491)
            backgroundStatusView.backgroundColor = UIColor(rgb: 0xE5F9F4)
            btnWent.isEnabled = false
            btnGoing.isEnabled = false
            btnFollow.setTitle("Followed", for: .normal)
        }
    }
    
    
    private func getDetailEvent(eventID : Int) {
        EventsDetailAPI(eventID: eventID).excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                let event = EventDetail(id: 0, photo: "", name: "Failed to load", descriptionHtml: "", scheduleStartDate: "", scheduleEndDate: "", scheduleStartTime: "", scheduleEndTime: "", schedulePermanent: "", goingCount: 0, nameGenre: "", vnLocation: "", vnContact: "", vnName: "", locationEvent: "")
                self?.eventDetail = event
                self?.setUpDataForView()
            } else {
                self?.eventDetail = response!.eventDetail
                self?.setUpDataForView()
            }
        }) { (err) in
            self.showAlert(message: "No internet connection", titleBtn: "OK") {
                print("No connection")
            }
        }
    }
    
    private func getListEventNear() {
          ArtWorkListAPI(radius: 10, longitue: self.eventDetail.longValue, latitude: self.eventDetail.latValue).excute(completionHandler: { [weak self] (response) in
              if response?.statusCode == 0 {
                  self?.showAlert(message: response!.errMessage, titleBtn: "alert.titleBtn.OK".localized) {
                      print(response!.errMessage!)
                  }
              } else {
                self?.eventsNear.removeAll()
                self?.eventsNear = response!.listEventsNear
                self?.eventCollection.reloadData()
              }
          }) { (err) in
            self.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "alert.titleBtn.OK".localized) {
                print("Can't get data")
            }
        }
    }
    
    private func handleLoginView() {
         let tabbarController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! TabbarViewController
         tabbarController.isLoginVC = true
         UIApplication.shared.windows.first?.rootViewController = tabbarController
         UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    
    private func goingEvent() {
        UpdateEventStatusAPI(status: 1, eventID: id!).excute(completionHandler: { [weak self] (response) in
            if response?.updateModel.status == 1 {
                self?.showAlert(message: "alert.goingThisEvent".localized, titleBtn: "alert.titleBtn.OK".localized, completion: {
                     self!.getDetailEvent(eventID: self!.id!)
                })
            } else {
                self?.showAlert(message: "alert.reLogin".localized, titleBtn: "alert.titleBtn.OK".localized) {
                    print(response!.updateModel.errorMessage)
                }
            }
        }) { (err) in
            self.showAlert(message: "alert.connectFailed.text".localized, titleBtn: "alert.titleBtn.OK".localized) {
                print(err!)
            }
        }
    }
    
    private func wentEvent() {
        UpdateEventStatusAPI(status: 2, eventID: id!).excute(completionHandler: { [weak self] (response) in
            if response?.updateModel.status == 1 {
                self?.showAlert(message: "alert.wentThisEvent".localized, titleBtn: "alert.titleBtn.OK".localized, completion: {
                     self!.getDetailEvent(eventID: self!.id!)
                })
            } else {
                self?.showAlert(message: "alert.reLogin".localized, titleBtn: "alert.titleBtn.OK".localized) {
                    print(response!.updateModel.errorMessage)
                }
            }
        }) { (err) in
            self.showAlert(message: "alert.connectFailed.text".localized, titleBtn: "alert.titleBtn.OK".localized) {
                print(err!)
            }
        }
    }
    
    @IBAction func handleReadmore(_ sender: Any) {
        if desDetail.numberOfLines == 0 {
            btnReadmore.setTitle("Read more..", for: .normal)
            desDetail.numberOfLines = 4
            desDetail.lineBreakMode = .byWordWrapping
            desDetail.sizeToFit()
        } else {
            desDetail.numberOfLines = 0
            desDetail.lineBreakMode = .byWordWrapping
            desDetail.sizeToFit()
            btnReadmore.setTitle("Less...", for: .normal)
        }
    }
    
    @IBAction func handleFollow(_ sender: Any) {
        if checkLoggedIn() {
            showAlert(message: "Not logged in".localized, titleBtn: "alert.titleBtn.OK".localized) {
                self.handleLoginView()
            }
        }
    }

    
    @IBAction func handleGoingEvent(_ sender: Any) {
        if checkLoggedIn() {
            showAlert(message: "Not logged in".localized, titleBtn: "alert.titleBtn.OK".localized) {
                self.handleLoginView()
            }
        } else {
            if eventDetail.mystatus != 1 {
                self.goingEvent()
            } else {
                ToastView.shared.short(self.view, txt_msg: "Already join this event")
            }
        }
    }
    

    @IBAction func handleWentEvent(_ sender: Any) {
        if checkLoggedIn() {
            showAlert(message: "Not logged in".localized, titleBtn: "alert.titleBtn.OK".localized) {
                self.handleLoginView()
            }
        } else {
            if eventDetail.mystatus != 2 {
                self.wentEvent()
            } else {
                ToastView.shared.short(self.view, txt_msg: "Already join this event")
            }
        }
    }
}



extension EventDetailV2Controller : UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventsNear.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = eventCollection.dequeueReusableCell(withReuseIdentifier: "EventsCell", for: indexPath) as! EventsCell
        let url = URL(string: eventsNear[indexPath.row].photo)
        cell.imgEvent!.sd_setImage(with: url, placeholderImage: UIImage(named: "noImage"), completed: nil)
        cell.eventName.text = eventsNear[indexPath.row].name
        cell.eventDes.attributedText = eventsNear[indexPath.row].descriptionHtml.htmlToAttributedString
        cell.eventCount.text = "\(eventsNear[indexPath.row].scheduleStartDate) - \(eventsNear[indexPath.row].goingCount) people going"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: eventCollection.frame.width, height: eventCollection.frame.height)
    }
}
