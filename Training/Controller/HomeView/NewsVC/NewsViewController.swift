//
//  NewsViewController.swift
//  Training
//
//  Created by ManhLD on 12/11/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage


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
    private var isLoadmore : Bool = false
    private var alert = UIAlertController()
    private let realm = try! Realm()
    private let dateFormatter = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        checkFirstLaunchDaily()
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
            updateObject()
            loading.handleLoading(isLoading: false)
        } else {
            loading.handleLoading(isLoading: true)
            getNewsData(shoudLoadmore: false, page: currentPage)
        }
    }
    
    
    
    private func detechDailyFirstLaunch() -> Bool {
        let today = NSDate().formatted
        if (UserDefaults.standard.string(forKey: "FIRSTLAUNCHNEWS") == today) {
            print("alert.detechlaunched.already".localized)
            return false
        } else {
            print("alert.detechlaunched.first".localized)
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
        newsResponse.removeAll()
        let list = realm.objects(NewsDataResponse.self).toArray(ofType: NewsDataResponse.self)
        newsResponse = list
        newsTable.reloadData()
    }
    
    
    private func deleteObject() {
        let list = realm.objects(NewsDataResponse.self).toArray(ofType: NewsDataResponse.self)
        try! realm.write {
            realm.delete(list)
        }
    }
    
    private func addObject(object : Object) {
        try! realm.write {
            realm.add(object)
        }
    }
    
    
    private func getNewsData(shoudLoadmore: Bool, page: Int) {
        NewsListAPI(pageIndex: page, pageSize: 10).excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                self?.showAlert(message: response?.errMessage ?? "", titleBtn: "OK", completion: {
                    print(response?.errMessage ?? "")
                })
            } else {
                if shoudLoadmore == false {
                    self?.newsResponse.removeAll()
                    self?.deleteObject()
                    response!.listNews.forEach { (news) in
                        self?.addObject(object: news)
                    }
                    self?.updateObject()
                } else {
                    for news in response!.listNews {
                        self?.addObject(object: news)
                    }
                    self?.updateObject()
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

// MARK: - Extension table

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsResponse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsTable.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        cell.lblDes.text = "By \(newsResponse[indexPath.row].author) - From \(newsResponse[indexPath.row].feed)"
        cell.title.text = newsResponse[indexPath.row].title
        cell.date.text = "\(newsResponse[indexPath.row].publishdate)"
        cell.backgroundStatusView.isHidden = true
        cell.statusImage.isHidden = true
        cell.statusLabel.isHidden = true
        cell.imgNews!.sd_setImage(with: URL(string: newsResponse[indexPath.row].thumbImg), placeholderImage: UIImage(named: "noImage"), completed: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = newsResponse.count - 1
        if indexPath.row == lastItem && isLoadmore == true {
            currentPage += 1
            getNewsData(shoudLoadmore: true, page: currentPage)
        } else {
            loading.handleLoading(isLoading: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let webViewVC = WebViewController()
        webViewVC.urlToOpen = newsResponse[indexPath.row + 1].url
        present(webViewVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
