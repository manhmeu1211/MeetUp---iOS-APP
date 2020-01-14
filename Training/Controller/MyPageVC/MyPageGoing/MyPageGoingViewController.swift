//
//  MyPageGoingViewController.swift
//  Training
//
//  Created by ManhLD on 12/20/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import RealmSwift

class MyPageGoingViewController: UIViewController {
    


    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var noEvents: UILabel!
    @IBOutlet weak var goingTable: UITableView!
    private let refreshControl = UIRefreshControl()
    
    
    private var alertLoading = UIAlertController()
    private let status = 1
    private var goingEvents = [MyPageGoingResDatabase]()
    private var goingEventsEnd = [MyPageGoingResDatabase]()
    private let userToken = UserDefaults.standard.string(forKey: "userToken")
    private let today = Date()
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getListGoingEvent()
    }

    private func checkEvent() {
        if goingEvents.isEmpty && goingEventsEnd.isEmpty {
            noEvents.isHidden = false
        } else {
            noEvents.isHidden = true
        }
    }
    
    private func setupView() {
        loading.handleLoading(isLoading: true)
        noEvents.isHidden = true
        goingTable.delegate = self
        goingTable.dataSource = self
        goingTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        if #available(iOS 10.0, *) {
             self.goingTable.refreshControl = refreshControl
         } else {
             self.goingTable.addSubview(refreshControl)
         }
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
    }
    
    @objc private func updateData() {
        getListGoingEvent()
        refreshControl.endRefreshing()
    }
    
    private func updateObject() {
        let list = realm.objects(MyPageGoingResDatabase.self).toArray(ofType: MyPageGoingResDatabase.self)
        goingEvents = list
    }
    
    private func deleteObject() {
       let list = realm.objects(MyPageGoingResDatabase.self).toArray(ofType: MyPageGoingResDatabase.self)
         try! realm.write {
             realm.delete(list)
        }
    }
    
    private func addObject(object : Object) {
        try! realm.write {
            realm.add(object)
        }
    }
       
    
    private func handleLogOut() {
        UserDefaults.standard.removeObject(forKey: "userToken")
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    private func getListGoingEvent() {
        MyPageGoingsListAPI(status: self.status).excute(completionHandler: { [weak self] (response) in
             if response?.status == 0 {
                self?.showAlert(message: response!.errMessage, titleBtn: "OK", completion: {
                    print(response!.errMessage!)
                    self?.handleLogOut()
                })
             } else {
                self?.deleteObject()
                self?.goingEvents.removeAll()
                let data = response?.listEventsGoings
                self?.goingEvents = data!
                for eventGoing in self!.goingEvents {
                    self?.addObject(object: eventGoing)
                }
                self?.goingTable.reloadData()
            }
        }) { (err) in
            self.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "OK", completion: {
                print(err!)
            })
            self.updateObject()
            self.goingTable.reloadData()
        }
         self.loading.handleLoading(isLoading: false)
    }
}


extension MyPageGoingViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return goingEvents.count
        default:
            return goingEventsEnd.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if goingEvents.count == 0 {
                return ""
            }
            return "eventsIsGoing.section.text".localized
        default:
            if goingEventsEnd.count == 0 {
                return ""
            }
            return "eventsEnded.section.text".localized
        }
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = goingTable.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            let url = URL(string: goingEvents[indexPath.row].photo)
            cell.statusImage.image = UIImage(named: "icon_starRed")
            cell.imgTimer.image = UIImage(named: "Group15")
            cell.imgNews.sd_setImage(with: url, completed: nil)
            cell.statusLabel.text = "Can participate"
            cell.statusLabel.textColor = UIColor(rgb: 0xC63636)
            cell.date.textColor = UIColor(rgb: 0x5D20CD)
            cell.backgroundStatusView.backgroundColor = UIColor(rgb: 0xF9EBEB)
            cell.date.text = "\(goingEvents[indexPath.row].scheduleStartDate) - \(goingEvents[indexPath.row].goingCount) people going"
            cell.title.text = goingEvents[indexPath.row].name
            cell.lblDes.attributedText = goingEvents[indexPath.row].descriptionHtml.htmlToAttributedString
            return cell
        default:
            let cell = goingTable.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            let url = URL(string: goingEventsEnd[indexPath.row].photo)
            cell.statusImage.image = UIImage(named: "icon_starRed")
            cell.imgTimer.image = UIImage(named: "Group15")
            cell.imgNews.sd_setImage(with: url, completed: nil)
            cell.backgroundStatusView.backgroundColor = UIColor(rgb: 0xF9EBEB)
            cell.date.textColor = UIColor(rgb: 0x5D20CD)
            cell.statusLabel.text = "Can participate"
            cell.statusLabel.textColor = UIColor(rgb: 0xC63636)
            cell.date.text = "\(goingEventsEnd[indexPath.row].scheduleStartDate) - \(goingEventsEnd[indexPath.row].goingCount) " + "peopleGoing.text".localized
            cell.title.text = goingEventsEnd[indexPath.row].name
            cell.lblDes.text = goingEventsEnd[indexPath.row].descriptionHtml
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let eventDetailVC = EventDetailController(nibName: "EventDetailView", bundle: nil)
        switch indexPath.section {
        case 0:
            eventDetailVC.id = goingEvents[indexPath.row].id
        default:
            eventDetailVC.id = goingEventsEnd[indexPath.row].id
        }
        present(eventDetailVC, animated: true, completion: nil)
    }
    
}
