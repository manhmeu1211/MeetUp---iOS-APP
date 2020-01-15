//
//  PopularsViewController.swift
//  Training
//
//  Created by ManhLD on 12/11/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import RealmSwift

class PopularsViewController: UIViewController {
    
    
    // MARK: - Outlet
    @IBOutlet weak var popularsTable: UITableView!
    
    // MARK: - Varribles
    @IBOutlet weak var loading: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    private var popularResponse = [PopularsResDatabase]()
    private var currentPage = 1
    private var isLoadmore : Bool!
    private var changeColor : Int!
    private var userToken = UserDefaults.standard.string(forKey: "userToken")
    private var headers = [String : String]()
    private let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        getDataFirstLaunch()
        checkConnection()
    }

    
    // MARK: - Function check before get data
    
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
                isLoadmore = false
            case .online(.wwan):
                isLoadmore = true
            case .online(.wiFi):
                isLoadmore = true
        }
    }
    
    
    private func getDataFirstLaunch() {
        if detechDailyFirstLaunch() == false {
            updateObject()
            popularsTable.reloadData()
        } else {
            upDateDataV2()
        }
    }
    
    private func detechDailyFirstLaunch() -> Bool {
        let today = NSDate().formatted
        if (UserDefaults.standard.string(forKey: "FIRSTLAUNCHPOPULARS") == today) {
        print("alert.detechlaunched.already".localized)
            return false
        } else {
        print("alert.detechlaunched.first".localized)
            UserDefaults.standard.setValue(today, forKey:"FIRSTLAUNCHPOPULARS")
            return true
        }
    }
    
    
    // MARK: - Function set up table and get data
 
    private func setUpTable() {
        loading.handleLoading(isLoading: false)
        popularsTable.dataSource = self
        popularsTable.delegate = self
        popularsTable.rowHeight = UITableView.automaticDimension
        popularsTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        if #available(iOS 10.0, *) {
             self.popularsTable.refreshControl = refreshControl
         } else {
             self.popularsTable.addSubview(refreshControl)
         }
        refreshControl.addTarget(self, action: #selector(upDateDataV2), for: .valueChanged)
    }
    
 
    @objc func upDateDataV2() {
        getListPopularData(isLoadMore: false, page: currentPage)
        refreshControl.endRefreshing()
    }
    
    
    private func updateObject() {
        let list = realm.objects(PopularsResDatabase.self).sorted(byKeyPath: "goingCount", ascending: false).toArray(ofType: PopularsResDatabase.self)
        self.popularResponse = list
    }
    
    private func deleteObject() {
       let list = realm.objects(PopularsResDatabase.self).toArray(ofType: PopularsResDatabase.self)
         try! realm.write {
             realm.delete(list)
        }
    }
    
    private func addObject(object : Object) {
        try! realm.write {
            realm.add(object)
        }
    }
      
    private func getListPopularData(isLoadMore : Bool, page : Int) {
        EventsListAPI(pageIndex: page, pageSize: 10).excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                self?.showAlert(message: response!.errMessage, titleBtn: "OK", completion: {
                    print(response!.errMessage!)
                })
            } else {
                if isLoadMore == false {
                    self?.popularResponse.removeAll()
                    self?.deleteObject()
                    for events in response!.listPopulars {
                        self?.addObject(object: events)
                    }
                    self?.updateObject()
                    self?.popularsTable.reloadData()
                } else {
                    for events in response!.listPopulars {
                        self?.addObject(object: events)
                    }
                    self?.updateObject()
                    self?.popularsTable.reloadData()
                }
            }
        }) { (err) in
            self.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "alert.titleBtn.OK".localized, completion: {
            print("Failed to load Data")
            self.isLoadmore = false
            self.updateObject()
            self.loading.handleLoading(isLoading: false)
            })
        }
    }
}

// MARK: - extension Table

extension PopularsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popularResponse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        let url = URL(string: popularResponse[indexPath.row].photo)
        cell.imgNews.sd_setImage(with: url, placeholderImage: UIImage(named: "noImage"), completed: nil)
        cell.date.textColor = UIColor(rgb: 0x5D20CD)
        cell.date.text = "\(popularResponse[indexPath.row].scheduleStartDate) - \(popularResponse[indexPath.row].goingCount) " + "peopleGoing.text".localized
        cell.title.text = popularResponse[indexPath.row].name
        cell.lblDes.attributedText = popularResponse[indexPath.row].descriptionHtml.htmlToAttributedString
        cell.imgTimer.image = UIImage(named: "Group15")
        switch popularResponse[indexPath.row].myStatus {
            case 1:
                cell.statusImage.image = UIImage(named: "icon_starRed")
                cell.statusLabel.text = "join.label.text.canParticipate".localized
                cell.statusLabel.textColor = UIColor(rgb: 0xC63636)
                cell.backgroundStatusView.backgroundColor = UIColor(rgb: 0xF9EBEB)
            case 2:
                cell.statusImage.image = UIImage(named: "icon_starGreen")
                cell.statusLabel.text = "join.label.text.joined".localized
                cell.backgroundStatusView.backgroundColor = UIColor(rgb: 0xE5F9F4)
                cell.statusLabel.textColor = UIColor(rgb: 0x00C491)
            default:
                cell.statusImage.image = UIImage(named: "icon_star")
                cell.statusLabel.text = "join.label.text.join".localized
                cell.backgroundStatusView.backgroundColor = UIColor(rgb: 0xF6F6F6)
                cell.statusLabel.textColor = UIColor.systemGray
        }
        return cell
    }
    
  
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = popularResponse.count - 1
        if indexPath.row == lastItem && isLoadmore == true {
            currentPage += 1
            loading.handleLoading(isLoading: false)
            getListPopularData(isLoadMore: true, page: currentPage)
        } else {
            loading.handleLoading(isLoading: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = popularResponse[indexPath.row].id
        let detailVCV2 = EventDetailV3Controller(nibName: "EventDetailV3Controller", bundle: nil)
        detailVCV2.id = id
        present(detailVCV2, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
