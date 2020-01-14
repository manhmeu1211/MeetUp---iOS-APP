//
//  EventDetailController.swift
//  Training
//
//  Created by ManhLD on 12/20/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import RealmSwift

class EventDetailController: UIViewController {

    @IBOutlet weak var detailTable: UITableView!
    @IBOutlet var swipeGes: UISwipeGestureRecognizer!
    
    private let realm = try! Realm()
    private var eventDetail = EventDetail()
    private var eventsNear = [EventsNearResponse]()
    var id : Int?
    private let userToken = UserDefaults.standard.string(forKey: "userToken")
    private var alertLogin = UIAlertController()
    var expandCellHeight : CGFloat = 88.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        getDetailEvent(eventID: id!)
        getListEvent()
    }
    
    private func setUpView() {
        detailTable.dataSource = self
        detailTable.delegate = self
        detailTable.register(UINib(nibName: "ImgDetailCell", bundle: nil), forCellReuseIdentifier: "ImgDetailCell")
        detailTable.register(UINib(nibName: "TextAreaCell", bundle: nil), forCellReuseIdentifier: "TextAreaCell")
        detailTable.register(UINib(nibName: "DetailVenueCell", bundle: nil), forCellReuseIdentifier: "DetailVenueCell")
        detailTable.register(UINib(nibName: "DetailNearCell", bundle: nil), forCellReuseIdentifier: "DetailNearCell")
        detailTable.register(UINib(nibName: "ButtonFooterCell", bundle: nil), forCellReuseIdentifier: "ButtonFooterCell")
        detailTable.rowHeight = UITableView.automaticDimension
        detailTable.allowsSelection = false
        detailTable.showsVerticalScrollIndicator = false
        self.tabBarController?.tabBar.isHidden = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    

    
    private func checkLoggedIn() -> Bool {
        if userToken != nil {
            return true
        }
        return false
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
    
    private func getDetailEvent(eventID : Int) {
        EventsDetailAPI(eventID: eventID).excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                let event = EventDetail(id: 0, photo: "", name: "Failed to load", descriptionHtml: "", scheduleStartDate: "", scheduleEndDate: "", scheduleStartTime: "", scheduleEndTime: "", schedulePermanent: "", goingCount: 0, nameGenre: "", vnLocation: "", vnContact: "", vnName: "", locationEvent: "")
                self?.eventDetail = event
            } else {
                self?.eventDetail = response!.eventDetail
            }
            self?.detailTable.reloadData()
        }) { (err) in
            self.showAlert(message: "No internet connection", titleBtn: "OK") {
                print("No connection")
            }
        }
    }
    

    private func getListEvent() {
        ArtWorkListAPI(radius: 10, longitue: self.eventDetail.longValue, latitude: self.eventDetail.latValue).excute(completionHandler: { [weak self] (response) in
            if response?.statusCode == 0 {
                self?.showAlert(message: response!.errMessage, titleBtn: "alert.titleBtn.OK".localized) {
                    print(response!.errMessage!)
                }
            } else {
                self?.eventsNear.removeAll()
                self?.eventsNear = response!.listEventsNear
            }
        }) { (err) in
            self.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "alert.titleBtn.OK".localized) {
                   print("Can't get data")
               }
        }
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
    
    @IBAction func backtoHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension EventDetailController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
             let cell = detailTable.dequeueReusableCell(withIdentifier: "ImgDetailCell", for: indexPath) as! ImageDetailCell
             cell.detailTitle.text = eventDetail.name
             cell.locationEvent.text = eventDetail.locationEvent
             let url = URL(string: eventDetail.photo)
             cell.imgDetail.sd_setImage(with: url, placeholderImage: UIImage(named: "noImage"),  completed: nil)
             if eventDetail.goingCount == 0 {
                 cell.detailDate.text = "\(eventDetail.scheduleStartDate) "
             } else {
                 cell.detailDate.text = "\(eventDetail.scheduleStartDate) - \(eventDetail.goingCount) people going"
             }
             
             if eventDetail.mystatus == 1 {
                DispatchQueue.main.async {
                    cell.imgStar.image = UIImage(named: "icon_starRed")
                    cell.status.text = "join.label.text.canParticipate".localized
                    cell.status.textColor = UIColor(rgb: 0xC63636)
                    cell.backGroundStatus.backgroundColor = UIColor(rgb: 0xF9EBEB)
                }
             } else if eventDetail.mystatus == 2 {
                DispatchQueue.main.async {
                    cell.imgStar.image = UIImage(named: "icon_starGreen")
                    cell.status.text = "join.label.text.joined".localized
                    cell.status.textColor = UIColor(rgb: 0x00C491)
                    cell.backGroundStatus.backgroundColor = UIColor(rgb: 0xE5F9F4)
                }
             }
             return cell
        case 1:
            let cell = detailTable.dequeueReusableCell(withIdentifier: "TextAreaCell", for: indexPath) as! TextAreaCell
            cell.txtView.text = eventDetail.descriptionHtml.replacingOccurrences(of: "[|<>/]", with: "", options: [.regularExpression])
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(expand))
            cell.txtView.addGestureRecognizer(tapGes)
            return cell
        case 2:
            let cell = detailTable.dequeueReusableCell(withIdentifier: "DetailVenueCell", for: indexPath) as! DetailVenueCell
            cell.btnFollow.isHidden = false
            cell.vnName.text = "Venue: "
            cell.vnDetail.text = eventDetail.vnName
            cell.btnFollow.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
            if eventDetail.mystatus == 2 {
                cell.btnFollow.setTitle("Followed", for: .normal)
            }
            return cell
        case 3:
            let cell = detailTable.dequeueReusableCell(withIdentifier: "DetailVenueCell", for: indexPath) as! DetailVenueCell
            cell.btnFollow.isHidden = true
            cell.vnName.text = "Genre: "
            cell.vnDetail.text = eventDetail.nameGenre
            return cell
        case 4:
            let cell = detailTable.dequeueReusableCell(withIdentifier: "DetailVenueCell", for: indexPath) as! DetailVenueCell
             cell.btnFollow.isHidden = true
             cell.vnName.text = "Location: "
             cell.vnDetail.text = eventDetail.vnLocation
             return cell
        case 6:
            let cell = detailTable.dequeueReusableCell(withIdentifier: "DetailNearCell", for: indexPath) as! DetailNearCell
            cell.updateData(eventLoaded: eventsNear)
            return cell
        case 7:
            let cell = detailTable.dequeueReusableCell(withIdentifier: "ButtonFooterCell", for: indexPath) as! ButtonFooterCell
            cell.btnWent.addTarget(self, action: #selector(handleWent), for: UIControl.Event.touchUpInside)
            cell.btnGoing.addTarget(self, action: #selector(handleGoing), for: UIControl.Event.touchUpInside)
            if checkLoggedIn() == false {
                cell.btnGoing.backgroundColor = UIColor(rgb: 0xF6F6F6)
                cell.btnWent.backgroundColor = UIColor(rgb: 0xF6F6F6)
            } else {
                if eventDetail.mystatus == 1 {
                    cell.btnGoing.backgroundColor = UIColor.red
                } else if eventDetail.mystatus == 2 {
                    cell.btnWent.backgroundColor = UIColor.systemOrange
                    cell.btnWent.isEnabled = false
                    cell.btnGoing.isEnabled = false
                }
            }
            return cell
        default:
            let cell = detailTable.dequeueReusableCell(withIdentifier: "DetailVenueCell", for: indexPath) as! DetailVenueCell
             cell.btnFollow.isHidden = true
             cell.vnName.text = "Contact: "
             cell.vnDetail.text = eventDetail.vnContact
             return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableView.automaticDimension
        } else if indexPath.row == 1 {
            return expandCellHeight
        } else if indexPath.row == 2 {
            return 120
        } else if indexPath.row == 7  {
            return 50
        } else if indexPath.row == 6  {
            return 200
        } else {
            return 50
        }
    }
    
    
     
    
    @objc func expand() {
        expandCellHeight = estimateFrameForText(text: eventDetail.descriptionHtml).height
        detailTable.beginUpdates()
        detailTable.endUpdates()
    }
    
    func estimateFrameForText(text: String) -> CGRect {
           let size = CGSize(width: 200, height: 400)
           let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
           return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
 
    
    @objc func handleFollow() {
         if !checkLoggedIn() {
            showAlert(message: "Not logged in".localized, titleBtn: "alert.titleBtn.OK".localized) {
                self.handleLoginView()
            }
        }
    }
    
    @objc func handleGoing() {
        if !checkLoggedIn() {
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
    
    @objc func handleWent() {
        if !checkLoggedIn() {
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
