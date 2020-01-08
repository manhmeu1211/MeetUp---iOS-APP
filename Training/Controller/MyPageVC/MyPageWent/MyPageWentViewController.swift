//
//  MyPageWentViewController.swift
//  Training
//
//  Created by ManhLD on 12/20/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import RealmSwift

class MyPageWentViewController: UIViewController {

    @IBOutlet weak var noEvents: UILabel!
    @IBOutlet weak var wentTable: UITableView!
    let userToken = UserDefaults.standard.string(forKey: "userToken")
    private let status = 2
    private let realm = try! Realm()
    private var wentEvents = [MyPageWentResDatabase]()
    private var wentEventsEnd = [MyPageWentResDatabase]()
    private let today = Date()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if userToken != nil {
            getListGoingWent()
        } else {
            print("data loaded")
        }
    }
    
    private func setupView() {
        wentTable.delegate = self
        wentTable.dataSource = self
        wentTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        noEvents.isHidden = true
    }
    
    private func checkEvent() {
        if wentEvents.isEmpty  && wentEventsEnd.isEmpty {
             noEvents.isHidden = false
         } else {
             noEvents.isHidden = true
         }
     }
     
    
    private func updateObject() {
        self.wentEvents = RealmDataBaseQuery.getInstance.getObjects(type: MyPageWentResDatabase.self)!.sorted(byKeyPath: "goingCount", ascending: false).toArray(ofType: MyPageWentResDatabase.self)
    }
    
    
    private func handleLogin() {
        let tabbarController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! TabbarViewController
        tabbarController.isLoginVC = true
        UIApplication.shared.windows.first?.rootViewController = tabbarController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
         

    private func getListGoingWent() {
           let usertoken = UserDefaults.standard.string(forKey: "userToken")
           if usertoken == nil {
            showAlert(message: "haveToLogin.label.text".localized, titleBtn: "alert.titleBtn.login".localized) {
                self.handleLogin()
            }
           } else {
            getDataService.getInstance.getMyEventWent(status: self.status) { (events, errCode) in
                    if errCode == 0 {
                        self.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "alert.titleBtn.OK".localized) {
                            print("Can't get data")
                        }
                    } else if errCode == 1 {
                        self.wentEvents.removeAll()
                    let dateFormatter = Date()
                        for i in events {
                             let date = dateFormatter.converStringToDate(formatter: Date.StyleDate.dateOnly, dateString: i.scheduleStartDate)
                             if date! < self.today {
                                self.wentEventsEnd.append(i)
                             } else {
                                self.wentEvents.append(i)
                            }
                         }
                        self.wentTable.reloadData()
                        self.checkEvent()
                    }  else {
                        self.updateObject()
                        self.wentTable.reloadData()
                        ToastView.shared.short(self.view, txt_msg: "alert.checkConnection".localized)
                    }
                }
            }
        }
    }


extension MyPageWentViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return wentEvents.count
        default:
            return wentEventsEnd.count
        }
    }
      
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if wentEvents.count == 0 {
                  return ""
            }
            return "eventsGoing.text".localized
        default:
            if wentEventsEnd.count == 0 {
                  return ""
            }
            return "eventsEnd.text".localized
        }
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = wentTable.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            let queue = DispatchQueue(label: "getListGoingEvent")
            queue.async {
                DispatchQueue.main.async {
                    cell.imgTimer.image = UIImage(named: "Group15")
                    cell.date.textColor = UIColor(rgb: 0x5D20CD)
                    cell.imgNews.image = UIImage(data: self.wentEvents[indexPath.row].photo)
                }
            }
            cell.date.text = "\(wentEvents[indexPath.row].scheduleStartDate) - \(wentEvents[indexPath.row].goingCount) " + "peopleGoing.text".localized
            cell.title.text = wentEvents[indexPath.row].name
            cell.lblDes.text = wentEvents[indexPath.row].descriptionHtml
            DispatchQueue.main.async {
                cell.statusImage.image = UIImage(named: "icon_starGreen")
                cell.statusLabel.text = "join.label.text.joined".localized
                cell.backgroundStatusView.backgroundColor = UIColor(rgb: 0xE5F9F4)
                cell.statusLabel.textColor = UIColor(rgb: 0x00C491)
            }
            return cell
        default:
            let cell = wentTable.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            let queue = DispatchQueue(label: "getListGoingEvent")
            queue.async {
                DispatchQueue.main.async {
                    cell.imgTimer.image = UIImage(named: "Group15")
                    cell.date.textColor = UIColor(rgb: 0x5D20CD)
                    cell.imgNews.image = UIImage(data: self.wentEventsEnd[indexPath.row].photo)
                }
            }
            cell.date.text = "\(wentEventsEnd[indexPath.row].scheduleStartDate) - \(wentEventsEnd[indexPath.row].goingCount) " + "peopleGoing.text".localized
            cell.title.text = wentEventsEnd[indexPath.row].name
            cell.lblDes.text = wentEventsEnd[indexPath.row].descriptionHtml
            DispatchQueue.main.async {
                cell.statusImage.image = UIImage(named: "icon_starGreen")
                cell.statusLabel.text = "join.label.text.joined".localized
                cell.backgroundStatusView.backgroundColor = UIColor(rgb: 0xE5F9F4)
                cell.statusLabel.textColor = UIColor(rgb: 0x00C491)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let eventDetailVC = EventDetailController(nibName: "EventDetailView", bundle: nil)
        switch indexPath.section {
        case 0:
            eventDetailVC.id = wentEvents[indexPath.row].id
        default:
            eventDetailVC.id = wentEventsEnd[indexPath.row].id
        }
        present(eventDetailVC, animated: true, completion: nil)
    }

}
