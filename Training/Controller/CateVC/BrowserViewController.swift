//
//  BrowserViewController.swift
//  Training
//
//  Created by ManhLD on 12/11/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import RealmSwift

class BrowserViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var categoriesTable: UITableView!
     // MARK: - Varribles
    private var alertLoading = UIAlertController()
    private let refreshControl = UIRefreshControl()
    private var cateList = [CategoriesResDatabase]()
    private let userToken = UserDefaults.standard.string(forKey: "userToken")
    private let realm = try! Realm()
    
    private let listIcon = ["fan", "bag", "car", "grow", "dance", "mortarboard", "woman", "love", "food", "politics", "love", "politics", "heart", "Star", "language", "smile", "notebook", "film", "music", "newAge", "bike", "ghost", "family", "pet", "camera", "belief", "ufo", "profile-cate", "link", "football", "support", "artificial", "pen"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertLoading.createAlertLoading(target: self, isShowLoading: true)
        setUpBarButton()
        setupTable()
        getCateGories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
     // MARK: - setup View
    private func getCateGories() {
        let list = realm.objects(CategoriesResDatabase.self).toArray(ofType: CategoriesResDatabase.self)
        if list.isEmpty {
            getListCategories()
        } else {
            updateObject()
        }
    }
    
    private func setUpBarButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search,
        target: self, action: #selector(handleSearchViewController))
          self.tabBarController?.tabBar.isHidden = false
    }

  
    private func setupTable() {
        categoriesTable.delegate = self
        categoriesTable.dataSource = self
        categoriesTable.register(UINib(nibName: "CategoriesTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoriesTableViewCell")
        if #available(iOS 10.0, *) {
            self.categoriesTable.refreshControl = refreshControl
        } else {
            self.categoriesTable.addSubview(refreshControl)
        }
            self.refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
    }
    
     // MARK: - getData
    
    @objc func updateData() {
        getListCategories()
        self.refreshControl.endRefreshing()
    }
    
    private func updateObject() {
        cateList.removeAll()
        let list = realm.objects(CategoriesResDatabase.self).toArray(ofType: CategoriesResDatabase.self)
        cateList = list
        categoriesTable.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
       
    private func deleteObject() {
      let list = realm.objects(CategoriesResDatabase.self).toArray(ofType: CategoriesResDatabase.self)
        try! realm.write {
            realm.delete(list)
        }
    }
   
    private func addObject(object : Object) {
        try! realm.write {
           realm.add(object)
        }
    }
          
    
    private func getListCategories() {
        CategoriesListAPI().excute(completionHandler: { [weak self] (response) in
            if response?.status == 0 {
                self?.dismiss(animated: true, completion: nil)
                self?.showAlert(message: response!.errMessage, titleBtn: "alert.titleBtn.OK".localized) {
                    print(response!.errMessage!)
                }
            } else {
                self?.cateList.removeAll()
                self?.deleteObject()
                for categories in response!.listCategories {
                    self?.addObject(object: categories)
                }
                self?.updateObject()
                self?.categoriesTable.reloadData()
                self?.dismiss(animated: true, completion: nil)
            }
        }) { (err) in
                self.dismiss(animated: true, completion: nil)
                self.showAlert(message: "alert.cannotLoadData".localized, titleBtn: "alert.titleBtn.OK".localized) {
                print("Can't get data")
            }
        }
    }
    
    @objc func handleSearchViewController() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
      // MARK: - Actions
    @IBAction func handleSearchView(_ sender: Any) {
        let searchView = SearchViewController()
        navigationController?.pushViewController(searchView, animated: true)
    }
}

  // MARK: - Extension tableview

extension BrowserViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cateList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoriesTable.dequeueReusableCell(withIdentifier: "CategoriesTableViewCell", for: indexPath) as! CategoriesTableViewCell
        cell.lblName.text = cateList[indexPath.row].name
        cell.imgIcon.image = UIImage(named: listIcon[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let idCategories = cateList[indexPath.row].id
        let titleCategories = cateList[indexPath.row].name
        let eventByCateVC = EventsByCategoriesViewController()
        eventByCateVC.categoriesID = idCategories
        eventByCateVC.headerTitle = titleCategories
        navigationController?.pushViewController(eventByCateVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
