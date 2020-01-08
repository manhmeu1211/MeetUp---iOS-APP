//
//  SearchViewController.swift
//  Training
//
//  Created by ManhLD on 12/12/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController {

    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var viewBtn: UIView!
    @IBOutlet weak var incaditorView: UIView!
    @IBOutlet weak var incaditorLeading: NSLayoutConstraint!
    @IBOutlet weak var noResults: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var imgNoResult: UIImageView!
    private let refreshControl = UIRefreshControl()
    private let userToken = UserDefaults.standard.string(forKey: "userToken")
    private var currentPage = 1
    private var searchResultPast = [SearchResponseDatabase]()
    private var searchResultInComing = [SearchResponseDatabase]()
    private var alertLoading = UIAlertController()
    private var isHaveConnection : Bool!
    private var today = Date()
    private let dateFormatter = Date()
    private var isToggleResult = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVỉew()
        checkConnection()
    }
    
    private func setUpVỉew() {
        self.tabBarController?.tabBar.isHidden = true
        noResults.isHidden = true
        imgNoResult.isHidden = true
        txtSearch.delegate = self
        searchTable.dataSource = self
        searchTable.delegate = self
        searchTable.rowHeight = UITableView.automaticDimension
        searchTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        if #available(iOS 10.0, *) {
            self.searchTable.refreshControl = refreshControl
        } else {
            self.searchTable.addSubview(refreshControl)
        }
            self.refreshControl.addTarget(self, action: #selector(updateDataSeacrch), for: .valueChanged)
        loading.handleLoading(isLoading: false)
    }
    
    
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
                    self.noResults.text = "No internet connection"
                    self.noResults.isHidden = false
                    isHaveConnection = false
                case .online(.wwan):
                    self.noResults.isHidden = true
                    isHaveConnection = true
                case .online(.wiFi):
                    self.noResults.isHidden = true
                    isHaveConnection = true
            }
        print(isHaveConnection!)
     }



    private func handleSearch(isLoadMore : Bool, page : Int) {
        let keyword = txtSearch.text!
        getDataService.getInstance.search(pageIndex: page, pageSize: 10, keyword: keyword, isLoadMore: isLoadMore) { [weak self] (result, errcode) in
            if errcode == 0 {
                self?.noResults.text = "No results"
                self?.loading.handleLoading(isLoading: false)
            } else if errcode == 1 {
                if isLoadMore == false {
                    for i in result {
                        self?.searchResultInComing.removeAll()
                        self?.searchResultPast.removeAll()
                        let date = self?.dateFormatter.converStringToDate(formatter: Date.StyleDate.dateOnly, dateString: i.scheduleStartDate)
                        if date! < self!.today {
                            self?.searchResultPast.append(i)
                         } else {
                            self?.searchResultInComing.append(i)
                        }
                    }
                } else {
                    for i in result {
                        let date = self?.dateFormatter.converStringToDate(formatter: Date.StyleDate.dateOnly, dateString: i.scheduleStartDate)
                        if date! < self!.today {
                            self?.searchResultPast.append(i)
                         } else {
                            self?.searchResultInComing.append(i)
                        }
                    }
                }
                self?.searchTable.reloadData()
                if self!.searchResultInComing.isEmpty && self!.isToggleResult {
                    self?.noResults.isHidden = false
                    self?.imgNoResult.isHidden = false
                    self?.noResults.text = "search.noResultIncoming.text".localized
                } else {
                    self?.noResults.isHidden = true
                    self?.imgNoResult.isHidden = true
                }
                self?.loading.handleLoading(isLoading: false)
            } else {
                self?.noResults.text = "alert.cannotLoadData".localized
                self?.noResults.isHidden = false
                self?.loading.handleLoading(isLoading: false)
            }
        }
    }
    
    private func handleLogin() {
        let tabbarController = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home") as! TabbarViewController
        tabbarController.isLoginVC = true
        UIApplication.shared.windows.first?.rootViewController = tabbarController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    
    @objc func updateDataSeacrch() {
        handleSearch(isLoadMore: false, page: currentPage)
        refreshControl.endRefreshing()
    }
     
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
 
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
 
    @IBAction func clearText(_ sender: Any) {
        txtSearch.text = ""
    }
    
    
    @IBAction func incomingBtn(_ sender: Any) {
        incaditorLeading.constant = 0
        isToggleResult = true
        if searchResultInComing.isEmpty {
            noResults.isHidden = false
            noResults.text = "search.noResultIncoming.text".localized
            imgNoResult.isHidden = false
         } else {
            noResults.isHidden = true
            imgNoResult.isHidden = true
         }
        searchTable.reloadData()
    }
    
    
    @IBAction func pastBtn(_ sender: Any) {
        incaditorLeading.constant = viewBtn.frame.width/2
        isToggleResult = false
        if searchResultPast.isEmpty {
            noResults.isHidden = false
            imgNoResult.isHidden = false
            noResults.text = "search.noResultPast.text".localized
        } else {
            noResults.isHidden = true
            imgNoResult.isHidden = true
        }
        searchTable.reloadData()
    }
}



extension SearchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isHaveConnection == true {
            if userToken == nil {
                showAlert(message: "haveToLogin.label.text".localized, titleBtn: "alert.titleBtn.login".localized) {
                    self.handleLogin()
                }
                return false
            } else {
                self.loading.handleLoading(isLoading: true)
                handleSearch(isLoadMore: false, page: currentPage)
                searchTable.reloadData()
                view.endEditing(true)
                return true
            }
        } else {
            showAlert(message: "alert.checkConnection".localized, titleBtn: "alert.titleBtn.OK".localized) {
                print("No Internet")
            }
            view.endEditing(true)
            return false
        }
    }
}



extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch isToggleResult {
        case true:
            return searchResultInComing.count
        default:
            return searchResultPast.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTable.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        switch isToggleResult {
        case true:
            let queue = DispatchQueue(label: "loadImageSearch")
            queue.async {
                DispatchQueue.main.async {
                    cell.imgTimer.image = UIImage(named: "Group15")
                    cell.imgNews.image = UIImage(data: self.searchResultInComing[indexPath.row].photo)
                }
            }
            cell.date.textColor = UIColor(rgb: 0x5D20CD)
            cell.title.text = searchResultInComing[indexPath.row].name
            cell.lblDes.text = searchResultInComing[indexPath.row].descriptionHtml.replacingOccurrences(of: "[|<>/]", with: "", options: [.regularExpression])
                   
            if searchResultInComing[indexPath.row].goingCount == 0 {
                cell.date.text = "\(searchResultInComing[indexPath.row].scheduleStartDate) "
            } else {
                cell.date.text = "\(searchResultInComing[indexPath.row].scheduleStartDate) - \(searchResultInComing[indexPath.row].goingCount) " + "peopleGoing.text".localized
            }
        default:
            let queue = DispatchQueue(label: "loadImageSearch")
            queue.async {
                DispatchQueue.main.async {
                    cell.imgTimer.image = UIImage(named: "Group15")
                    cell.imgNews.image = UIImage(data: self.searchResultPast[indexPath.row].photo)
                }
            }
            cell.date.textColor = UIColor(rgb: 0x5D20CD)
            cell.title.text = searchResultPast[indexPath.row].name
            cell.lblDes.text = searchResultPast[indexPath.row].descriptionHtml.replacingOccurrences(of: "[|<>/]", with: "", options: [.regularExpression])
                   
            if searchResultPast[indexPath.row].goingCount == 0 {
                cell.date.text = "\(searchResultPast[indexPath.row].scheduleStartDate) "
            } else {
                cell.date.text = "\(searchResultPast[indexPath.row].scheduleStartDate) - \(searchResultPast[indexPath.row].goingCount) " + "peopleGoing.text".localized
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
      
      func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            switch isToggleResult {
            case true:
                let lastItem = searchResultInComing.count - 1
                  if indexPath.row == lastItem {
                    noResults.isHidden = true
                    currentPage += 1
                    loading.handleLoading(isLoading: true)
                    handleSearch(isLoadMore: true, page: currentPage)
                  }
            default:
                let lastItem = searchResultPast.count - 1
                  if indexPath.row == lastItem {
                    noResults.isHidden = true
                    currentPage += 1
                    loading.handleLoading(isLoading: true)
                    handleSearch(isLoadMore: true, page: currentPage)
                  }

            }
      }
}
