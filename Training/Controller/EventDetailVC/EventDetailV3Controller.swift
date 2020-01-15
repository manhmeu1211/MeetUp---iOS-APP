//
//  EventDetailV3Controller.swift
//  Training
//
//  Created by ManhLD on 1/15/20.
//  Copyright © 2020 ManhLD. All rights reserved.
//

import UIKit

class EventDetailV3Controller: UIViewController {

    @IBOutlet weak var imgDetail: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDetailLocation: UILabel!

    @IBOutlet weak var eventPeopleCount: UILabel!
    @IBOutlet weak var eventContact: UILabel!
    @IBOutlet weak var eventGenre: UILabel!
    @IBOutlet weak var eventMailContact: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventCollection: UICollectionView!
    @IBOutlet weak var btnGoing: UIButton!
    @IBOutlet weak var btnWent: UIButton!
    @IBOutlet weak var btnReadmore: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    
    private var eventsNear = [EventsNearResponse]()
    private var eventDetail = EventDetail()
    var id : Int?
    private let userToken = UserDefaults.standard.string(forKey: "userToken")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpCollectionView()
        getDetailEvent(eventID: id!)
    }
    
    private func setUpCollectionView() {
           eventCollection.delegate = self
           eventCollection.dataSource = self
           eventCollection.register(UINib(nibName: "EventsCell", bundle: nil), forCellWithReuseIdentifier: "EventsCell")
           eventCollection.showsHorizontalScrollIndicator = false
       }


    private func setUpView() {
        backgroundView.roundCornersView(radius: 30)
        btnWent.roundedButton()
        btnGoing.roundedButton()
        btnFollow.layer.borderColor = UIColor(rgb: 0x5D20CD).cgColor
        btnFollow.layer.borderWidth = 0.5
        btnFollow.layer.cornerRadius = 10
        backgroundView.layoutIfNeeded()
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
      
    
    private func checkLoggedIn() -> Bool {
           if userToken == nil {
               return true
           }
           return false
       }
      

    private func setUpDataForView() {
        let url = URL(string: eventDetail.photo)
        imgDetail.sd_setImage(with: url, placeholderImage: UIImage(named: "noImage"), completed: nil)
        eventTitle.text = eventDetail.name
        eventDate.text = eventDetail.scheduleStartDate
        eventPeopleCount.text = "\(eventDetail.goingCount) " + "peopleGoing.text".localized
        eventDetailLocation.text = eventDetail.vnLocation
        eventDescription.attributedText = eventDetail.descriptionHtml.htmlToAttributedString
        eventContact.text = eventDetail.vnName
        eventGenre.text = eventDetail.nameGenre
        eventContact.text = eventDetail.vnContact
        eventLocation.text = eventDetail.locationEvent
        if eventDetail.mystatus == 1 {
            btnGoing.backgroundColor = UIColor.red
        } else if eventDetail.mystatus == 2 {
            btnWent.backgroundColor = UIColor.systemOrange
            btnWent.isEnabled = false
            btnGoing.isEnabled = false
            btnFollow.setTitle("Followed", for: .normal)
        }
        getListEventNear()
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
        if eventDescription.numberOfLines == 0 {
             btnReadmore.setTitle("Read more..", for: .normal)
             eventDescription.numberOfLines = 4
             eventDescription.lineBreakMode = .byWordWrapping
             eventDescription.sizeToFit()
         } else {
             eventDescription.numberOfLines = 0
             eventDescription.lineBreakMode = .byWordWrapping
             eventDescription.sizeToFit()
             btnReadmore.setTitle("Less...", for: .normal)
         }
    }
    
    
    @IBAction func handleFollow(_ sender: Any) {
        
    }
    
    @IBAction func handleGoing(_ sender: Any) {
        
    }
    
    
    @IBAction func handleWent(_ sender: Any) {
        
    }
    
    @IBAction func handleGoback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


extension EventDetailV3Controller : UICollectionViewDataSource, UICollectionViewDelegate {
    
    
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
        return CGSize(width: eventCollection.frame.width - 10, height: 150)
    }
}
