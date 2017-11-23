//
//  ViewController.swift
//  Pizza
//
//  Created by Alexander Kosse on 14/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit
import RealmSwift

final class CityObject: Object {
    @objc dynamic var id = Int()
    @objc dynamic var title = String()
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class CategoryObject: Object {
    @objc dynamic var id = Int()
    @objc dynamic var title = String()
    @objc dynamic var icon = String()
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class ProductObject: Object {
    @objc dynamic var id = Int()
    @objc dynamic var categoryId = Int()
    @objc dynamic var cityId = Int()
    @objc dynamic var title = String()
    @objc dynamic var fullDescription = String()
    @objc dynamic var icon = String()
    @objc dynamic var favorite = false
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class CartItemObject: Object {
    @objc dynamic var productId = Int()
    @objc dynamic var productSize = Int()
    @objc dynamic var productType = Int()
    @objc dynamic var productCount = Int()
}

class CatalogController: UICollectionViewController, UISearchResultsUpdating, UISearchBarDelegate {

    private var refreshControl = UIRefreshControl()
    private var searchController = UISearchController()
    private var condencedLayout = false
    private var layoutChangeInProgress = false
    
    private var notificationToken: NotificationToken?
    
    private let products = try! Realm().objects(ProductObject.self)
    private let purchases = try! Realm().objects(CartItemObject.self)
    private let categories = try! Realm().objects(CategoryObject.self)

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            collectionView?.insetsLayoutMarginsFromSafeArea = true
            //navigationItem.searchController = searchController
        }
        refreshControl.addTarget(self, action: #selector(CatalogController.refreshAction), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = refreshControl
        } else {
            collectionView?.addSubview(refreshControl)
        }
        let nb = navigationController!.navigationBar.layer
//        nb.borderWidth = 1
//        nb.borderColor = navigationController?.navigationBar.barTintColor?.cgColor
        nb.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        nb.shadowOffset = CGSize(width: 0, height: 0)
        nb.shadowRadius = 3.0
        nb.shadowOpacity = 1.0
        nb.masksToBounds = false
        let tb = tabBarController!.tabBar.layer
//        tb.borderWidth = 1
//        tb.borderColor = tabBarController?.tabBar.barTintColor?.cgColor
        tb.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        tb.shadowOffset = CGSize(width: 0, height: 0)
        tb.shadowRadius = 3.0
        tb.shadowOpacity = 1.0
        tb.masksToBounds = false

        if products.count < 20 {
            let realm = try! Realm()
            try! realm.write {
                for i in 1...20 {
                    let product = ProductObject()
                    product.id = i
                    realm.add(product)
                }
            }
        }

        self.notificationToken = products.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.collectionView?.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.collectionView?.performBatchUpdates({
                    self.collectionView?.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                    self.collectionView?.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                    self.collectionView?.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                }, completion: { (completed) in })
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
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
        
        let currentlayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = collectionView!.safeAreaInsets
        }
        
        let columns = (size.width > size.height) ? 4 : 2 as CGFloat
        var width = (size.width-10-insets.left-insets.right-(columns-1)*2)/columns
        var height = width + 120
        if condencedLayout {
            width = size.width-insets.left-insets.right-8
            height = 100
        }
        let cellSize = CGSize(width: width, height: height)
        if currentlayout.itemSize == cellSize { return }

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

    @IBAction func favoriteAction(_ sender: UIButton) {
//        guard let button: UIButton = condencedLayout ? (sender.superview?.superview?.superview as! CondencedCell).favoriteButton : (sender.superview?.superview?.superview as! CatalogCell).favoriteButton else { return }
        let index = sender.superview!.superview!.superview!.tag
        let product = products[index]
        let realm = try! Realm()
        try! realm.write {
            product.favorite = !product.favorite
        }
        //button.isSelected = product.favorite
    }
    
    @IBAction func changeLayout(_ sender: UIButton) {
        condencedLayout = !condencedLayout
        if condencedLayout {
            sender.setImage(UIImage(named: "NormalCollection"), for: .normal)

        } else {
            sender.setImage(UIImage(named: "CompactCollection"), for: .normal)
        }
        //layoutChangeInProgress = true
        //collectionView?.reloadData()
        //layoutChangeInProgress = false
        updateLayout(size: collectionView!.bounds.size, animated: false)
        collectionView?.reloadData()
        //collectionView?.reloadSections([0])
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    ///////////////////////////// Collection View Delegate ///////////////////////////////
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if layoutChangeInProgress { return 0}
        return products.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let product = products[index]
        if condencedLayout {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CondencedCell", for: indexPath) as! CondencedCell
            cell.tag = index
            cell.favoriteButton.isSelected = product.favorite
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCell", for: indexPath) as! CatalogCell
            cell.tag = index
            cell.favoriteButton.isSelected = product.favorite
            return cell
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

