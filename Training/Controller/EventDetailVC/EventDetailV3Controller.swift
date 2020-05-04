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
    @IBOutlet weak var loading: UIActivityIndicatorView!
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
    
    @IBOutlet weak var eventContactDetail: UILabel!
    private var eventsNear = [EventsNearResponse]()
    private var eventDetail = EventDetail()
    var id : Int = 0
    private let userToken = UserDefaults.standard.string(forKey: "userToken")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpCollectionView()
        getDetailEvent(eventID: id)

    }
    
    override func viewWillAppear(_ animated: Bool) {
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backgroundView.center.x -= view.bounds.width
        eventDescription.center.y += view.bounds.height
        UIView.animate(withDuration: 0.7, delay: 0.2, options: [],
         animations: {
           self.backgroundView.center.x += self.view.bounds.width
         },
         completion: nil
        )
        UIView.animate(withDuration: 1, delay: 0.4, options: [],
         animations: {
            self.eventDescription.center.y -= self.view.bounds.height
         },
         completion: nil
        )
    }
    
    private func setUpCollectionView() {
           eventCollection.delegate = self
           eventCollection.dataSource = self
           eventCollection.register(UINib(nibName: "EventsCell", bundle: nil), forCellWithReuseIdentifier: "EventsCell")
           eventCollection.showsHorizontalScrollIndicator = false
       }


    private func setUpView() {
        loading.handleLoading(isLoading: true)
        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewDidLayoutSubviews() {
        backgroundView.roundCornersView(radius: 30)
        btnWent.roundedButton()
        btnGoing.roundedButton()
        btnFollow.layer.borderColor = UIColor(rgb: 0x5D20CD).cgColor
        btnFollow.layer.borderWidth = 0.5
        btnFollow.layer.cornerRadius = 10
  
    }
    
    
    @objc func swiped(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            id += 1
            getDetailEvent(eventID: id)
        } else if gesture.direction == .right {
            id -= 1
            getDetailEvent(eventID: id)
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
        eventDescription.text = eventDetail.descriptionHtml.htmlToString
        eventGenre.text = eventDetail.nameGenre
        eventLocation.text = eventDetail.locationEvent
        eventContactDetail.text = eventDetail.vnContact
        if eventDetail.mystatus == 1 {
            btnGoing.backgroundColor = UIColor.red
        } else if eventDetail.mystatus == 2 {
            btnWent.backgroundColor = UIColor.systemOrange
            btnWent.isEnabled = false
            btnGoing.isEnabled = false
            btnFollow.setTitle("Followed", for: .normal)
        } else if userToken == nil {
            btnGoing.backgroundColor = UIColor(rgb: 0xC8C5CD)
            btnWent.backgroundColor = UIColor(rgb: 0xC8C5CD)
        }
        else {
            btnGoing.backgroundColor = UIColor(rgb: 0x5D20CD)
            btnWent.backgroundColor = UIColor(rgb: 0x5D20CD)
        }
        print(eventDetail.mystatus)
        getListEventNear()

    }

    
    private func getDetailEvent(eventID : Int) {
        EventsDetailAPI(eventID: eventID).excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                let event = EventDetail(id: 0, photo: "", name: "alert.cannotLoadData".localized, descriptionHtml: "", scheduleStartDate: "", scheduleEndDate: "", scheduleStartTime: "", scheduleEndTime: "", schedulePermanent: "", goingCount: 0, nameGenre: "", vnLocation: "", vnContact: "", vnName: "", locationEvent: "")
                self?.eventDetail = event
                self?.setUpDataForView()
            } else {
                self?.eventDetail = response!.eventDetail
                self?.setUpDataForView()
            }
        }) { (err) in
            self.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "alert.titleBtn.OK".localized) {
                print("No connection")
            }
        }
    }
    
    private func getListEventNear() {
          ArtWorkListAPI(radius: 10, longitue: self.eventDetail.longValue, latitude: self.eventDetail.latValue).excute(completionHandler: { [weak self] (response) in
              if response?.statusCode == 0 {
                self?.loading.handleLoading(isLoading: false)
                  self?.showAlert(message: response?.errMessage ?? "", titleBtn: "alert.titleBtn.OK".localized) {
                    self?.eventsNear.append(EventsNearResponse(id: 0, photo: "", name: response?.errMessage ?? "", descriptionHtml: "", scheduleStartDate: "", scheduleEndDate: "", scheduleStartTime: "", scheduleEndTime: "", schedulePermanent: "", goingCount:0))
                    self?.eventCollection.reloadData()
                  }
              } else {
                self?.eventsNear.removeAll()
                self?.eventsNear = response!.listEventsNear
                self?.eventCollection.reloadData()
                self?.loading.handleLoading(isLoading: false)
              }
          }) { (err) in
            self.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "alert.titleBtn.OK".localized) {
                self.eventsNear.append(EventsNearResponse(id: 0, photo: "", name: "alert.cannotLoadData".localized, descriptionHtml: "", scheduleStartDate: "", scheduleEndDate: "", scheduleStartTime: "", scheduleEndTime: "", schedulePermanent: "", goingCount: 0))
                self.eventCollection.reloadData()
            }
            self.loading.handleLoading(isLoading: false)
        }
    }
    
    private func handleLoginView() {
         let tabbarController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! TabbarViewController
         tabbarController.isLoginVC = true
         UIApplication.shared.windows.first?.rootViewController = tabbarController
         UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    
    private func goingEvent() {
        UpdateEventStatusAPI(status: 1, eventID: id).excute(completionHandler: { [weak self] (response) in
            if response?.updateModel.status == 1 {
                self?.showAlert(message: "alert.goingThisEvent".localized, titleBtn: "alert.titleBtn.OK".localized, completion: {
                    self?.getDetailEvent(eventID: self?.id ?? 0)
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
        UpdateEventStatusAPI(status: 2, eventID: id).excute(completionHandler: { [weak self] (response) in
            if response?.updateModel.status == 1 {
                self?.showAlert(message: "alert.wentThisEvent".localized, titleBtn: "alert.titleBtn.OK".localized, completion: {
                     self?.getDetailEvent(eventID: self?.id ?? 0)
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
            btnReadmore.setTitle("readmore.titleBtn".localized, for: .normal)
             eventDescription.numberOfLines = 4
             eventDescription.lineBreakMode = .byWordWrapping
             eventDescription.sizeToFit()
         } else {
             eventDescription.numberOfLines = 0
             eventDescription.lineBreakMode = .byWordWrapping
             eventDescription.sizeToFit()
            btnReadmore.setTitle("less.titleBtn".localized, for: .normal)
         }
    }
    
    
    @IBAction func handleFollow(_ sender: Any) {
        if checkLoggedIn() {
            showAlert(message: "Not logged in".localized, titleBtn: "alert.titleBtn.OK".localized) {
                self.handleLoginView()
            }
        }
    }
    
    @IBAction func handleGoing(_ sender: Any) {
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
    
    
    @IBAction func handleWent(_ sender: Any) {
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
    
    @IBAction func handleGoback(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        cell.eventCount.text = "\(eventsNear[indexPath.row].scheduleStartDate)"
        cell.eventPeopleGoing.text = "\(eventsNear[indexPath.row].goingCount) " + "peopleGoing.text".localized
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: eventCollection.frame.width, height: eventCollection.frame.height)
    }
}
