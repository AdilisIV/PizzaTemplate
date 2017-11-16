//
//  ViewController.swift
//  Pizza
//
//  Created by Alexander Kosse on 14/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit

struct CityEntity {
    var id = Int()
    var title = String()
}

struct CategoryEntity {
    var id = Int()
    var title = String()
    var city = String()
    var icon = String()
}

struct ProductEntity {
    var id = Int()
    var categoryId = Int()
    var cityId = Int()
    var title = String()
    var description = String()
    var icon = String()
}

class CatalogController: UICollectionViewController, UISearchResultsUpdating, UISearchBarDelegate {

    private var refreshControl = UIRefreshControl()
    private var searchController = UISearchController()
    private var condencedLayout = false
    private var layoutChangeInProgress = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            collectionView?.insetsLayoutMarginsFromSafeArea = true
            navigationItem.searchController = searchController
        }
        refreshControl.addTarget(self, action: #selector(CatalogController.refreshAction), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = refreshControl
        } else {
            collectionView?.addSubview(refreshControl)
        }
        let sc = navigationController!.navigationBar.layer
        sc.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        sc.shadowOffset = CGSize(width: 0, height: 1.0)
        sc.shadowRadius = 2.0
        sc.shadowOpacity = 1.0
        sc.masksToBounds = false
        let tb = tabBarController!.tabBar.layer
        tb.borderWidth = 1
        tb.borderColor = tabBarController?.tabBar.barTintColor?.cgColor
        tb.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        tb.shadowOffset = CGSize(width: 0, height: 0.0)
        tb.shadowRadius = 3.0
        tb.shadowOpacity = 1.0
        tb.masksToBounds = false

        //tabBarController?.tabBar.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLayout(size: collectionView!.bounds.size, animated: false)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        updateLayout(size: collectionView!.bounds.size, animated: false)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let color = UIColor.DarkCoral()
        guard let verticalIndicator = scrollView.subviews.last as? UIImageView,
            verticalIndicator.backgroundColor != color,
            verticalIndicator.image?.renderingMode != .alwaysTemplate
            else { return }
        verticalIndicator.layer.masksToBounds = true
        verticalIndicator.layer.cornerRadius = verticalIndicator.frame.width / 2
        verticalIndicator.backgroundColor = color
        verticalIndicator.image = verticalIndicator.image?.withRenderingMode(.alwaysTemplate)
        verticalIndicator.tintColor = .clear
    }
    
    @objc func refreshAction() {
        refreshControl.endRefreshing()
    }
    
    func updateLayout(size: CGSize, animated: Bool) {
        
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = collectionView!.safeAreaInsets
        }
        
        let columns = (size.width > size.height) ? 4 : 2 as CGFloat
        var width = (size.width-10-insets.left-insets.right-(columns-1)*2)/columns
        var height = width + 120
        if condencedLayout {
            width = size.width-insets.left-insets.right-16
            height = 100
        }
        let cellSize = CGSize(width: width, height: height)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4)
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 2
        if #available(iOS 11.0, *) {
            layout.sectionInsetReference = .fromSafeArea
        }
        collectionView?.setCollectionViewLayout(layout, animated: animated)
    }

    @IBAction func changeLayout(_ sender: UIButton) {
        condencedLayout = !condencedLayout
        if condencedLayout {
            sender.setImage(UIImage(named: "NormalCollection"), for: .normal)

        } else {
            sender.setImage(UIImage(named: "CompactCollection"), for: .normal)
        }
        layoutChangeInProgress = true
        collectionView?.reloadData()
        layoutChangeInProgress = false
        updateLayout(size: collectionView!.bounds.size, animated: false)
        //collectionView?.reloadSections([0])
    }
    
    ///////////////////////////// Collection View Delegate ///////////////////////////////
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if layoutChangeInProgress { return 0}
        return 20
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if condencedLayout {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CondencedCell", for: indexPath) as! CatalogCell
            return cell as UICollectionViewCell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCell", for: indexPath) as! CatalogCell
            return cell as UICollectionViewCell
        }
//        DispatchQueue.main.async {
//            cell.imageView.kf.setImage(with: URL(string: "https://4k.com/wp-content/uploads/2014/06/4k-image-tiger-jumping.jpg")!)
//        }
    }
    
    ///////////////////////////// Search Results Delegate ///////////////////////////
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //searchActive = false
    }
}

