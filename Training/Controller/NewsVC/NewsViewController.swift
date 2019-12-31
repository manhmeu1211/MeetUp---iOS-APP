//
//  NewsViewController.swift
//  Training
//
//  Created by ManhLD on 12/11/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import RealmSwift


class NewsViewController: UIViewController {
    
  // MARK: - Outlets
 
    @IBOutlet weak var newsTable: UITableView!
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var loading: UIActivityIndicatorView!
    // MARK: - Varrible
    

    private var currentPage = 1
    private var newsResponse = [NewsDataResponse]()
    private let dateformatted = DateFormatter()
    private let userToken = UserDefaults.standard.string(forKey: "userToken")
    private var isLoadmore : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        checkFirstLaunchDaily()
        checkTokenExpired()
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
    
    private func checkFirstLaunchDaily() {
        if detechDailyFirstLaunch() == false {
            checkTokenExpired()
            updateObject()
            loading.handleLoading(isLoading: false)
        } else {
            loading.handleLoading(isLoading: true)
            getNewsData(shoudLoadmore: false, page: currentPage)
        }
    }
    
    private func checkTokenExpired() {
        if userToken != nil {
            let headers = [ "Authorization": "Bearer \(userToken!)",
                        "Content-Type": "application/json"  ]
            getDataService.getInstance.getMyEventGoing(status: 1) { (json, errCode) in
                if errCode == 0 {
                    UserDefaults.standard.removeObject(forKey: "userToken")
                } else {
                    print("Token is avaible")
                }
            }
        } else {
            print("Not logged in")
        }
    }
    

  
    private func detechDailyFirstLaunch() -> Bool {
         let today = NSDate().formatted
         if (UserDefaults.standard.string(forKey: "FIRSTLAUNCHNEWS") == today) {
             print("already launched")
             return false
         } else {
             print("first launch")
             UserDefaults.standard.setValue(today, forKey:"FIRSTLAUNCHNEWS")
             return true
         }
     }
    
    // MARK: - Function set up table and get data
    
    private func setUpTable() {
        newsTable.dataSource = self
        newsTable.delegate = self
        newsTable.rowHeight = UITableView.automaticDimension
        newsTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        if #available(iOS 10.0, *) {
            self.newsTable.refreshControl = refreshControl
        } else {
            self.newsTable.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
    }
    
    
    @objc func updateData() {
        getNewsData(shoudLoadmore: false, page: currentPage)
        self.refreshControl.endRefreshing()
    }

    private func updateObject() {
        let list = RealmDataBaseQuery.getInstance.getObjects(type: NewsDataResponse.self)!.toArray(ofType: NewsDataResponse.self)
        newsResponse = list
    }
    
    private func getNewsData(shoudLoadmore: Bool, page: Int) {
        getDataService.getInstance.getListNews(pageIndex: page, pageSize: 10, shoudLoadmore: shoudLoadmore) { (news, errCode) in
            if errCode == 1 {
                if shoudLoadmore == false {
                    self.newsResponse.removeAll()
                    self.newsResponse = news
                } else {
                    self.newsResponse = news
                }
                self.newsTable.reloadData()
                self.dismiss(animated: true, completion: nil)
            } else {
                print("No data")
                self.isLoadmore = false
                self.updateObject()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Extension table

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsResponse.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsTable.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        let queue = DispatchQueue(label: "loadImageNews")
        queue.async {
             DispatchQueue.main.async {
                cell.imgNews.image = UIImage(data: self.newsResponse[indexPath.row].thumbImg)
            }
        }
        cell.lblDes.text = "By \(newsResponse[indexPath.row].author) - From \(newsResponse[indexPath.row].feed)"
        cell.title.text = newsResponse[indexPath.row].title
        cell.date.text = "\(newsResponse[indexPath.row].publishdate)"
        cell.backgroundStatusView.isHidden = true
        cell.statusImage.isHidden = true
        cell.statusLabel.isHidden = true
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == newsResponse.count - 2 && isLoadmore == true {
            loading.handleLoading(isLoading: true)
            currentPage += 1
            self.getNewsData(shoudLoadmore: true, page: currentPage)
        } else {
            loading.handleLoading(isLoading: false)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let vc = WebViewController()
        vc.urlToOpen = newsResponse[indexPath.row + 1].url
        present(vc, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
