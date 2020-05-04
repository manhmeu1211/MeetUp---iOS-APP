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
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getListGoingWent()
    }
    

    private func setupView() {
        wentTable.delegate = self
        wentTable.dataSource = self
        wentTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        noEvents.isHidden = true
        if #available(iOS 10.0, *) {
             self.wentTable.refreshControl = refreshControl
         } else {
             self.wentTable.addSubview(refreshControl)
         }
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
    }
    
    @objc private func updateData() {
        getListGoingWent()
        wentTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    
    
    private func checkEvent() {
        if wentEvents.isEmpty  && wentEventsEnd.isEmpty {
             noEvents.isHidden = false
         } else {
             noEvents.isHidden = true
         }
     }
     
    
    private func updateObject() {
        let list = realm.objects(MyPageWentResDatabase.self).sorted(byKeyPath: "goingCount", ascending: false).toArray(ofType: MyPageWentResDatabase.self)
        wentEvents = list
    }
    
    
    private func handleLogin() {
        let tabbarController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! TabbarViewController
        tabbarController.isLoginVC = true
        UIApplication.shared.windows.first?.rootViewController = tabbarController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
         

    private func getListGoingWent() {
        MyPageWentListAPI(status: status).excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                self?.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "OK", completion: {
                    print(response?.errMessage ?? "Token expired")
                })
            } else {
                if let list = self?.realm.objects(MyPageWentResDatabase.self).toArray(ofType: MyPageWentResDatabase.self) {
                    try! self?.realm.write {
                        self?.realm.delete(list)
                    }
                }

                self?.wentEvents.removeAll()
                if let data = response?.listEventsWent {
                     self?.wentEvents = data
                }
                
                for eventWent in self?.wentEvents ?? [] {
                    try! self?.realm.write {
                        self?.realm.add(eventWent)
                    }
                }
                self?.wentTable.reloadData()
            }
        }) { (err) in
            self.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "OK", completion: {
                print(err ?? "")
            })
            self.updateObject()
            self.wentTable.reloadData()
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
        guard let cell = wentTable.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell else {
            return UITableViewCell()
        }
        switch indexPath.section {
          
        case 0:
            let url = URL(string: wentEvents[indexPath.row].photo)
            cell.imgTimer.image = UIImage(named: "Group15")
            cell.date.textColor = UIColor(rgb: 0x5D20CD)
            cell.imgNews.sd_setImage(with: url, completed: nil)
            cell.date.text = "\(wentEvents[indexPath.row].scheduleStartDate) - \(wentEvents[indexPath.row].goingCount) " + "peopleGoing.text".localized
            cell.title.text = wentEvents[indexPath.row].name
            cell.lblDes.attributedText = wentEvents[indexPath.row].descriptionHtml.htmlToAttributedString
            DispatchQueue.main.async {
                cell.statusImage.image = UIImage(named: "icon_starGreen")
                cell.statusLabel.text = "join.label.text.joined".localized
                cell.backgroundStatusView.backgroundColor = UIColor(rgb: 0xE5F9F4)
                cell.statusLabel.textColor = UIColor(rgb: 0x00C491)
            }
            
        default:
            let url = URL(string: wentEventsEnd[indexPath.row].photo)
            cell.imgTimer.image = UIImage(named: "Group15")
            cell.date.textColor = UIColor(rgb: 0x5D20CD)
            cell.imgNews.sd_setImage(with: url, completed: nil)
            cell.date.text = "\(wentEventsEnd[indexPath.row].scheduleStartDate) - \(wentEventsEnd[indexPath.row].goingCount) " + "peopleGoing.text".localized
            cell.title.text = wentEventsEnd[indexPath.row].name
            cell.lblDes.text = wentEventsEnd[indexPath.row].descriptionHtml
            DispatchQueue.main.async {
                cell.statusImage.image = UIImage(named: "icon_starGreen")
                cell.statusLabel.text = "join.label.text.joined".localized
                cell.backgroundStatusView.backgroundColor = UIColor(rgb: 0xE5F9F4)
                cell.statusLabel.textColor = UIColor(rgb: 0x00C491)
            }
           
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let eventDetailVC = EventDetailV3Controller(nibName: "EventDetailV3Controller", bundle: nil)
        switch indexPath.section {
        case 0:
            eventDetailVC.id = wentEvents[indexPath.row].id
        default:
            eventDetailVC.id = wentEventsEnd[indexPath.row].id
        }
        present(eventDetailVC, animated: true, completion: nil)
    }

}
