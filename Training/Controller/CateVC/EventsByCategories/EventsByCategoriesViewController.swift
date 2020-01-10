//
//  EventsByCategoriesViewController.swift
//  Training
//
//  Created by ManhLD on 12/19/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import RealmSwift

class EventsByCategoriesViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var noResults: UILabel!
    @IBOutlet weak var titleCategories: UILabel!
    @IBOutlet weak var incaditorLeading: NSLayoutConstraint!
    @IBOutlet weak var incaditorView: UIView!
    @IBOutlet weak var eventTable: UITableView!
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Varribles
    
    var categoriesID : Int?
    var headerTitle : String?
    private var currentPage = 1
    private var eventsByCate = [EventsByCategoriesDatabase]()
    private let token = UserDefaults.standard.string(forKey: "userToken")
    private var isLoadmore = true
    private let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVỉew()
        loading.handleLoading(isLoading: true)
        getDataEventsByCategories(isLoadMore: false, page: currentPage)
    }
    
    
    
    // MARK: - Function setup views and data
    
//    private func getDataEventV2() {
//        if token != nil {
//            getDataEventsByCategories(isLoadMore: false, page: currentPage)
//            noResults.isHidden = true
//        } else {
//            noResults.isHidden = false
//            loading.handleLoading(isLoading: false)
//            showAlert(message: "Not logged in".localized, titleBtn: "alert.titleBtn.OK".localized) {
//
//            }
//        }
//    }
//

    private func setupVỉew() {
        noResults.isHidden = true
        eventTable.dataSource = self
        eventTable.delegate = self
        eventTable.rowHeight = UITableView.automaticDimension
        eventTable.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
        titleCategories.text = "\(headerTitle!)(\(eventsByCate.count))"
        if #available(iOS 10.0, *) {
            self.eventTable.refreshControl = refreshControl
        } else {
            self.eventTable.addSubview(refreshControl)
        }
        refreshControl.attributedTitle = NSAttributedString(string: "refreshingData.text".localized)
        refreshControl.addTarget(self, action: #selector(upDateData), for: .valueChanged)
    }
    
    
    @objc func upDateData() {
          getDataEventsByCategories(isLoadMore: false, page: currentPage)
          refreshControl.endRefreshing()
      }
  
    private func updateObjectByPopulars() {
        let listEventByGoingCount = realm.objects(EventsByCategoriesDatabase.self).sorted(byKeyPath: "goingCount", ascending: false).toArray(ofType: EventsByCategoriesDatabase.self)
        self.eventsByCate = listEventByGoingCount
        checkEvent()
        eventTable.reloadData()
        self.titleCategories.text = "\(self.headerTitle!)(\(self.eventsByCate.count))"
    }
    
    private func checkEvent() {
        if eventsByCate.isEmpty {
            noResults.isHidden = false
            noResults.text = "noEvents.text".localized
        } else {
            noResults.isHidden = true
        }
    }
    
    private func updateObjectByDate() {
        let listEventByDate = realm.objects(EventsByCategoriesDatabase.self).sorted(byKeyPath: "scheduleStartDate", ascending: false).toArray(ofType: EventsByCategoriesDatabase.self)
        eventsByCate = listEventByDate
        checkEvent()
        eventTable.reloadData()
        self.titleCategories.text = "\(self.headerTitle!)(\(self.eventsByCate.count))"
    }

    private func deleteObject() {
       let list = realm.objects(EventsByCategoriesDatabase.self).toArray(ofType: EventsByCategoriesDatabase.self)
         try! realm.write {
             realm.delete(list)
         }
     }
    
     private func addObject(object : Object) {
         try! realm.write {
            realm.add(object)
         }
     }

    func getDataEventsByCategories(isLoadMore : Bool, page: Int) {
        EventsByCategoriesListAPI(pageIndex: page, pageSize: 10, categoriesID: categoriesID!).excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                self?.showAlert(message: response!.errMessage, titleBtn: "alert.titleBtn.OK".localized, completion: {
                    self?.loading.handleLoading(isLoading: false)
                })
            } else {
                if isLoadMore == false {
                    self?.eventsByCate.removeAll()
                    self?.deleteObject()
                    for eventByCate in response!.listEventsByCate {
                        self?.addObject(object: eventByCate)
                    }
                    self?.updateObjectByDate()
                    self?.eventTable.reloadData()
                } else {
                    for eventByCate in response!.listEventsByCate {
                        self?.addObject(object: eventByCate)
                    }
                    self?.updateObjectByDate()
                    self?.eventTable.reloadData()
                }
                self?.loading.handleLoading(isLoading: false)
            }
        }) { (err) in
                self.loading.handleLoading(isLoading: false)
                self.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "alert.titleBtn.OK".localized) {
                self.isLoadmore = false
                print("Can't get data")
            }
        }

    }
    
    
    // MARK: - Actions
    
    @IBAction func byPopulars(_ sender: Any) {
        eventsByCate.removeAll()
        updateObjectByPopulars()
        eventTable.reloadData()
        incaditorLeading.constant = 0
    }
    
    
    @IBAction func byDate(_ sender: Any) {
        eventsByCate.removeAll()
        updateObjectByDate()
        eventTable.reloadData()
        incaditorLeading.constant = incaditorView.frame.width/2
    }
    
    
    @IBAction func backBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toSearchViewBtn(_ sender: Any) {
        let searchView = SearchViewController()
        navigationController?.pushViewController(searchView, animated: true)
    }
}


// MARK: - Extension tableview

extension EventsByCategoriesViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsByCate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventTable.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        let url = URL(string: eventsByCate[indexPath.row].photo)
        cell.imgTimer.image = UIImage(named: "Group15")
        cell.imgNews.sd_setImage(with: url, completed: nil)
        cell.date.textColor = UIColor(rgb: 0x5D20CD)
        cell.date.text = "\(eventsByCate[indexPath.row].scheduleStartDate) - \(eventsByCate[indexPath.row].goingCount) " + "peopleGoing.text".localized
        cell.title.text = eventsByCate[indexPath.row].name
        cell.lblDes.text = eventsByCate[indexPath.row].descriptionHtml
        cell.backgroundStatusView.isHidden = true
        cell.statusImage.isHidden = true
        cell.statusLabel.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = eventsByCate.count - 1
        if indexPath.row == lastItem && isLoadmore == true {
            currentPage += 1
            getDataEventsByCategories(isLoadMore: true, page: currentPage)
        }
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let name = eventsByCate[indexPath.row].name
       print(name)
    }
       
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return UITableView.automaticDimension
    }
}
